import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexuschat_app/core/services/api_client.dart';
import 'package:nexuschat_app/core/services/socket_service.dart';
import 'package:nexuschat_app/features/chat/domain/models/chat_model.dart';
import 'package:nexuschat_app/features/chat/domain/models/message_model.dart';

class ChatRepository {
  final Dio _dio;
  final SocketService _socketService;

  ChatRepository(this._dio, this._socketService);

  /// Creates a new chat or returns existing chat with the specified user
  Future<ChatModel> createOrGetChat(String userId) async {
    try {
      final response = await _dio.post('/chats', data: {'recipientId': userId});
      final data = response.data['data'];
      return ChatModel.fromJson(data);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to create chat';
    }
  }

  /// Fetch all chats for the current user
  Future<List<ChatModel>> getChats() async {
    try {
      final response = await _dio.get('/chats');
      final data = response.data['data'] as List;
      return data.map((e) => ChatModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch chats';
    }
  }

  /// Fetch messages for a specific chat
  Future<List<MessageModel>> getMessages(String chatId, String currentUserId) async {
    try {
      final response = await _dio.get('/chats/$chatId/messages');
      final data = response.data['data']['messages'] as List;
      return data.map((e) => MessageModel.fromJson(e, currentUserId)).toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch messages';
    }
  }

  void sendMessage({
    required String chatId,
    required String content,
    required Function(dynamic) onAck,
  }) {
    _socketService.sendMessage(chatId, content, onAck);
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(
    ref.watch(apiClientProvider),
    ref.watch(socketServiceProvider),
  );
});
