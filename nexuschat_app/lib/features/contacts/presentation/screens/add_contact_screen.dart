import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexuschat_app/features/contacts/presentation/providers/contact_search_provider.dart';
import 'package:nexuschat_app/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:nexuschat_app/features/contacts/presentation/widgets/contact_search_result_item.dart';

class AddContactScreen extends ConsumerStatefulWidget {
  const AddContactScreen({super.key});

  @override
  ConsumerState<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends ConsumerState<AddContactScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _addingUsers = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addContact(String userId) async {
     setState(() {
      _addingUsers.add(userId);
    });
    try {
      await ref.read(contactSearchProvider(userId).notifier).addContact(userId);
      if (mounted) {
        setState(() {
          _addingUsers.remove(userId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact added successfully')),
        );
        // Refresh contacts list
        ref.invalidate(contactsProvider);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _addingUsers.remove(userId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add contact: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only search if query is not empty to save API calls
    final searchResults = ref.watch(contactSearchProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Contact'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by username or email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              onChanged: (value) {
                // Debounce simple
                 setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _searchQuery.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: Colors.grey[600]),
                        const SizedBox(height: 16),
                        Text(
                          'Search for people to add',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : searchResults.when(
                    data: (users) {
                      if (users.isEmpty) {
                         return Center(
                          child: Text(
                            'No users found for "$_searchQuery"',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return ContactSearchResultItem(
                            user: user,
                            isAdding: _addingUsers.contains(user.id),
                            onAdd: () => _addContact(user.id),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('Error: $error')),
                  ),
          ),
        ],
      ),
    );
  }
}
