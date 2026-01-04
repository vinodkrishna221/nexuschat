import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nexuschat_app/features/contacts/domain/models/contact.dart';

class ContactListItem extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback onChat;

  const ContactListItem({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Avatar with status indicator
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: contact.user.avatar != null
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(contact.user.avatar!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.grey[800],
                  ),
                  child: contact.user.avatar == null
                      ? Center(
                          child: Text(
                            contact.user.username[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                ),
                if (contact.user.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Name and Status
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.user.displayName ?? contact.user.username,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    contact.user.isOnline 
                      ? 'Online' 
                      : contact.user.status ?? 'Offline',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: contact.user.isOnline ? Colors.green : Colors.grey,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Chat Button
            IconButton(
              icon: Icon(
                Icons.chat_bubble_outline,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: onChat,
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
