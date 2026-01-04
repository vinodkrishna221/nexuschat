import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexuschat_app/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:nexuschat_app/features/contacts/presentation/widgets/contact_list_item.dart';
import 'package:nexuschat_app/features/contacts/domain/models/contact.dart';
import 'package:nexuschat_app/features/chat/data/repositories/chat_repository.dart';
import 'package:nexuschat_app/core/ui/widgets/empty_state_widget.dart';
import 'package:nexuschat_app/core/ui/widgets/error_screen.dart';
import 'package:nexuschat_app/core/services/toast_service.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contactsState = ref.watch(contactsProvider);

    return Scaffold(
      body: contactsState.when(
        data: (contacts) {
          // Filter contacts
          final filteredContacts = contacts.where((contact) {
            final query = _searchQuery.toLowerCase();
            final name = (contact.user.displayName ?? contact.user.username).toLowerCase();
            return name.contains(query);
          }).toList();

          // Group by Online / All (simplified for now)
          filteredContacts.sort((a, b) {
            final aName = a.user.displayName ?? a.user.username;
            final bName = b.user.displayName ?? b.user.username;
            return aName.compareTo(bName);
          });

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                title: const Text('Contacts'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person_add),
                    onPressed: () => context.push('/contacts/add'),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SearchBar(
                      controller: _searchController,
                      hintText: 'Search contacts...',
                      leading: const Icon(Icons.search),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).cardColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
              if (contacts.isEmpty)
                SliverFillRemaining(
                  child: NoContactsEmptyState(
                    onAddContact: () => context.push('/contacts/add'),
                  ),
                )
              else if (filteredContacts.isEmpty && _searchQuery.isNotEmpty)
                SliverFillRemaining(
                  child: NoSearchResultsEmptyState(query: _searchQuery),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final contact = filteredContacts[index];
                      // Swipe Actions
                      return Dismissible(
                        key: Key(contact.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Remove Contact?"),
                                content: Text("Are you sure you want to remove ${contact.user.displayName ?? contact.user.username}?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text("CANCEL"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text("REMOVE", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) {
                          ref.read(contactsProvider.notifier).removeContact(contact.id);
                        },
                        child: ContactListItem(
                          contact: contact,
                          onTap: () {
                             // Show profile/details modal or navigate
                             // For now, just print
                             print('Tapped contact: ${contact.user.username}');
                          },
                          onChat: () async {
                            // Create or get existing chat and navigate
                            try {
                              final chatRepo = ref.read(chatRepositoryProvider);
                              final chat = await chatRepo.createOrGetChat(contact.user.id);
                              if (context.mounted) {
                                context.push('/chat/${chat.id}', extra: chat);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to start chat: $e')),
                                );
                              }
                            }
                          },
                        ),
                      );
                    },
                    childCount: filteredContacts.length,
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: InlineError(
            message: 'Failed to load contacts',
            onRetry: () => ref.invalidate(contactsProvider),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/contacts/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
