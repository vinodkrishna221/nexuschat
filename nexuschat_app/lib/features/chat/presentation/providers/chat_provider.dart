import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexuschat_app/core/services/socket_service.dart';
import 'package:nexuschat_app/features/chat/domain/models/message_model.dart';
import 'package:nexuschat_app/features/chat/data/repositories/chat_repository.dart';
import 'package:nexuschat_app/features/profile/presentation/providers/profile_provider.dart';

// State for the active chat messages
class ChatState {
  final List<MessageModel> messages;
  final bool isLoading;
  final String? currentUserId;

  ChatState({this.messages = const [], this.isLoading = false, this.currentUserId});

  ChatState copyWith({List<MessageModel>? messages, bool? isLoading, String? currentUserId}) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _repository;
  final SocketService _socketService;

  ChatNotifier(this._repository, this._socketService, String? userId) 
      : super(ChatState(currentUserId: userId)) {
    _initSocketListeners();
  }

  void _initSocketListeners() {
    _socketService.onNewMessage((data) {
      if (data == null) return;
      _handleNewMessage(data);
    });
  }

  void updateUserId(String? userId) {
    state = state.copyWith(currentUserId: userId);
  }

  void _handleNewMessage(dynamic data) {
    final userId = state.currentUserId;
    if (userId == null) return;
    try {
      final message = MessageModel.fromJson(data, userId);
      state = state.copyWith(
        messages: [message, ...state.messages],
      );
    } catch (e) {
      print('Error parsing new message: $e');
    }
  }
  
  void joinChat(String chatId) {
    _socketService.joinChat(chatId);
    final userId = state.currentUserId;
    if (userId != null) {
      _loadHistory(chatId, userId);
    }
  }

  Future<void> _loadHistory(String chatId, String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      final messages = await _repository.getMessages(chatId, userId);
      // API returns Oldest -> Newest. We want Newest -> Oldest for reverse list.
      state = state.copyWith(messages: messages.reversed.toList(), isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print('Failed to load history: $e');
    }
  }
  
  void leaveChat(String chatId) {
    _socketService.leaveChat(chatId);
    state = state.copyWith(messages: []); 
  }

  void sendMessage(String chatId, String content) {
    final userId = state.currentUserId;
    print('sendMessage called: chatId=$chatId, content=$content, userId=$userId');
    if (content.trim().isEmpty || userId == null) {
      print('sendMessage early return: isEmpty=${content.trim().isEmpty}, userIdNull=${userId == null}');
      return;
    }

    // Optimistic update
    final tempId = DateTime.now().toString();
    final optimisticMessage = MessageModel(
      id: tempId,
      text: content,
      senderId: userId,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      isMe: true,
    );

    state = state.copyWith(
      messages: [optimisticMessage, ...state.messages],
    );

    _repository.sendMessage(
      chatId: chatId,
      content: content,
      onAck: (response) {
        if (response['success'] == true) {
           print('Message sent successfully: ${response['message']}');
        } else {
           print('Message send failed: ${response['error']}');
        }
      },
    );
  }

  @override
  void dispose() {
    _socketService.offNewMessage();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  final socketService = ref.watch(socketServiceProvider);
  final profile = ref.watch(profileProvider).valueOrNull;
  
  final notifier = ChatNotifier(repository, socketService, profile?.id);
  
  // Listen for profile changes and update userId
  ref.listen(profileProvider, (previous, next) {
    final userId = next.valueOrNull?.id;
    notifier.updateUserId(userId);
  });
  
  return notifier;
});
