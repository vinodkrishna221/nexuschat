import 'package:flutter/material.dart';
import 'package:nexuschat_app/features/chat/domain/models/chat_model.dart';
import 'package:intl/intl.dart';

class ChatItem extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;

  const ChatItem({
    super.key,
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Formatting date
    String formattedTime;
    final now = DateTime.now();
    final diff = now.difference(chat.lastMessageTime);

    if (diff.inDays == 0) {
      formattedTime = DateFormat('HH:mm').format(chat.lastMessageTime);
    } else if (diff.inDays < 7) {
      formattedTime = DateFormat('EEE').format(chat.lastMessageTime);
    } else {
      formattedTime = DateFormat('dd/MM/yy').format(chat.lastMessageTime);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar with Online Indicator
              Stack(
                children: [
                  Hero(
                    tag: chat.id,
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(chat.avatarUrl),
                      backgroundColor: theme.colorScheme.primaryContainer,
                    ),
                  ),
                  if (chat.isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              
              // Name and Last Message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chat.lastMessage,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Time and Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedTime,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (chat.unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        chat.unreadCount.toString(),
                        style: theme.textTheme.labelSmall?.copyWith(
                           fontSize: 10,
                           color: theme.colorScheme.onPrimary,
                           fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 18), // Placeholder to keep alignment
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
