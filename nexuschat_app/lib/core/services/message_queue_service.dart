import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nexuschat_app/core/services/retry_service.dart';
import 'package:nexuschat_app/core/services/connectivity_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Status of a pending message in the queue
enum PendingMessageStatus {
  pending,
  sending,
  failed,
}

/// A message waiting to be sent
class PendingMessage {
  final String id;
  final String chatId;
  final String content;
  final String senderId;
  final DateTime createdAt;
  final int retryCount;
  final PendingMessageStatus status;

  PendingMessage({
    required this.id,
    required this.chatId,
    required this.content,
    required this.senderId,
    required this.createdAt,
    this.retryCount = 0,
    this.status = PendingMessageStatus.pending,
  });

  PendingMessage copyWith({
    int? retryCount,
    PendingMessageStatus? status,
  }) {
    return PendingMessage(
      id: id,
      chatId: chatId,
      content: content,
      senderId: senderId,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'chatId': chatId,
        'content': content,
        'senderId': senderId,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
        'status': status.index,
      };

  factory PendingMessage.fromJson(Map<String, dynamic> json) {
    return PendingMessage(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      content: json['content'] as String,
      senderId: json['senderId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      status: PendingMessageStatus.values[json['status'] as int? ?? 0],
    );
  }
}

/// Service for managing a queue of messages that failed to send
class MessageQueueService {
  static const String _boxName = 'pending_messages';
  Box<Map>? _box;
  final RetryService _retryService = RetryService();
  
  StreamController<List<PendingMessage>>? _queueController;
  bool _isProcessing = false;
  
  /// Callback to actually send the message
  Future<bool> Function(String chatId, String content)? onSendMessage;

  /// Stream of pending messages
  Stream<List<PendingMessage>> get pendingMessagesStream {
    _queueController ??= StreamController<List<PendingMessage>>.broadcast();
    return _queueController!.stream;
  }

  /// Initialize Hive box for persistence
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<Map>(_boxName);
    _notifyListeners();
    debugPrint('📦 MessageQueueService initialized with ${_box?.length ?? 0} pending messages');
  }

  /// Get all pending messages
  List<PendingMessage> getPendingMessages() {
    if (_box == null) return [];
    
    return _box!.values
        .map((map) => PendingMessage.fromJson(Map<String, dynamic>.from(map)))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Get pending messages for a specific chat
  List<PendingMessage> getPendingMessagesForChat(String chatId) {
    return getPendingMessages().where((m) => m.chatId == chatId).toList();
  }

  /// Add a message to the queue
  Future<void> enqueue(PendingMessage message) async {
    if (_box == null) {
      debugPrint('⚠️ MessageQueueService not initialized');
      return;
    }
    
    await _box!.put(message.id, message.toJson());
    debugPrint('📥 Enqueued message: ${message.id}');
    _notifyListeners();
  }

  /// Remove a message from the queue (after successful send)
  Future<void> dequeue(String messageId) async {
    await _box?.delete(messageId);
    debugPrint('📤 Dequeued message: $messageId');
    _notifyListeners();
  }

  /// Update a message in the queue
  Future<void> updateMessage(PendingMessage message) async {
    if (_box == null) return;
    await _box!.put(message.id, message.toJson());
    _notifyListeners();
  }

  /// Process the queue (called when connectivity is restored)
  Future<void> processQueue() async {
    if (_isProcessing || onSendMessage == null) return;
    if (_box == null || _box!.isEmpty) return;

    _isProcessing = true;
    debugPrint('🔄 Processing message queue...');

    final pending = getPendingMessages()
        .where((m) => m.status != PendingMessageStatus.sending)
        .toList();

    for (final message in pending) {
      // Update status to sending
      await updateMessage(message.copyWith(status: PendingMessageStatus.sending));

      final result = await _retryService.execute(
        () => onSendMessage!(message.chatId, message.content).then((success) {
          if (!success) throw Exception('Send failed');
          return success;
        }),
        config: RetryConfig.messageConfig,
        onRetry: (attempt, delay, error) {
          debugPrint('⏳ Retry $attempt for message ${message.id}');
        },
      );

      if (result.success) {
        await dequeue(message.id);
        debugPrint('✅ Message ${message.id} sent successfully');
      } else {
        await updateMessage(message.copyWith(
          retryCount: message.retryCount + result.attempts,
          status: PendingMessageStatus.failed,
        ));
        debugPrint('❌ Message ${message.id} failed after ${result.attempts} attempts');
      }
    }

    _isProcessing = false;
    debugPrint('✅ Queue processing complete');
  }

  /// Mark a message as failed (for manual retry)
  Future<void> markAsFailed(String messageId) async {
    final messages = getPendingMessages();
    final message = messages.where((m) => m.id == messageId).firstOrNull;
    if (message != null) {
      await updateMessage(message.copyWith(status: PendingMessageStatus.failed));
    }
  }

  /// Retry a specific failed message
  Future<void> retryMessage(String messageId) async {
    final messages = getPendingMessages();
    final message = messages.where((m) => m.id == messageId).firstOrNull;
    if (message != null) {
      await updateMessage(message.copyWith(status: PendingMessageStatus.pending));
      await processQueue();
    }
  }

  void _notifyListeners() {
    _queueController?.add(getPendingMessages());
  }

  Future<void> dispose() async {
    await _box?.close();
    await _queueController?.close();
    _queueController = null;
  }
}

/// Provider for MessageQueueService
final messageQueueServiceProvider = Provider<MessageQueueService>((ref) {
  final service = MessageQueueService();
  ref.onDispose(() => service.dispose());
  return service;
});
