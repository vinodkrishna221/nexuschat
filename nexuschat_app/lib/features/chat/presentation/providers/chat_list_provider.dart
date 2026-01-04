import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexuschat_app/features/chat/domain/models/chat_model.dart';
import 'package:nexuschat_app/features/chat/data/repositories/chat_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_list_provider.g.dart';

/// State for chat list with loading, error, and data states
@riverpod
class ChatList extends _$ChatList {
  @override
  FutureOr<List<ChatModel>> build() async {
    return _fetchChats();
  }

  Future<List<ChatModel>> _fetchChats() async {
    final repository = ref.read(chatRepositoryProvider);
    try {
      final chats = await repository.getChats();
      return chats;
    } catch (e) {
      // If fetch fails, return empty list but rethrow for error handling
      rethrow;
    }
  }

  /// Refresh the chat list
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchChats());
  }

  /// Optimistically add a new chat to the list
  void addChat(ChatModel chat) {
    final currentChats = state.valueOrNull ?? [];
    // Check if chat already exists
    if (!currentChats.any((c) => c.id == chat.id)) {
      state = AsyncData([chat, ...currentChats]);
    }
  }

  /// Update last message for a chat
  void updateLastMessage(String chatId, String message, DateTime time) {
    final currentChats = state.valueOrNull ?? [];
    final index = currentChats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      final updatedChat = ChatModel(
        id: currentChats[index].id,
        name: currentChats[index].name,
        avatarUrl: currentChats[index].avatarUrl,
        lastMessage: message,
        lastMessageTime: time,
        unreadCount: currentChats[index].unreadCount,
        isOnline: currentChats[index].isOnline,
      );
      final newList = [...currentChats];
      newList[index] = updatedChat;
      // Sort by last message time
      newList.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      state = AsyncData(newList);
    }
  }
}

/// Provider that tracks if there are any chats
@riverpod
bool hasChats(HasChatsRef ref) {
  final chatList = ref.watch(chatListProvider);
  return chatList.whenOrNull(data: (chats) => chats.isNotEmpty) ?? false;
}
