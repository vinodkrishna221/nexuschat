import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexuschat_app/features/chat/domain/models/chat_model.dart';
import 'package:nexuschat_app/features/chat/domain/models/chat_model.dart';
import 'package:nexuschat_app/features/chat/presentation/widgets/chat_input.dart';
import 'package:nexuschat_app/features/chat/presentation/widgets/message_bubble.dart';
import 'package:nexuschat_app/features/chat/presentation/providers/chat_provider.dart';
import 'package:nexuschat_app/features/chat/presentation/widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final ChatModel? chat; 

  const ChatScreen({
    super.key,
    required this.chatId,
    this.chat,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  // ignore: unused_field
  final bool _isTyping = false; // TODO: Connect to real typing events

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       ref.read(chatProvider.notifier).joinChat(widget.chatId);
    });
  }
  
  @override
  void dispose() {
    // Might want to leave chat only when completely done, 
    // or keep it open for a bit. For now, we leave when screen closes.
    // ref.read(chatProvider.notifier).leaveChat(widget.chatId); // Be careful if using global provider for multiple chats
    super.dispose();
  }

  void _sendMessage(String text) {
    ref.read(chatProvider.notifier).sendMessage(widget.chatId, text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatState = ref.watch(chatProvider);
    
    // Fallback if chat object not passed
    final chatName = widget.chat?.name ?? 'User';
    final chatAvatar = widget.chat?.avatarUrl ?? 'https://i.pravatar.cc/150';
    final isOnline = widget.chat?.isOnline ?? false;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Hero(
              tag: widget.chatId,
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(chatAvatar),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chatName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isOnline)
                  Text(
                    'Online', // TODO: Listen to presence updates
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  )
                else
                  Text(
                    'Offline',
                    style: theme.textTheme.bodySmall?.copyWith(
                       color: Colors.grey,
                       fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: 20),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final message = chatState.messages[index];
                return MessageBubble(message: message);
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8),
              child: TypingIndicator(),
            ),
          ChatInput(onSend: _sendMessage),
        ],
      ),
    );
  }
}
