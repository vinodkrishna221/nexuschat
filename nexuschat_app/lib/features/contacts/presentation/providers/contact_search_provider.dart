import 'package:nexuschat_app/features/contacts/data/repositories/contacts_repository.dart';
import 'package:nexuschat_app/features/profile/domain/models/user_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'contact_search_provider.g.dart';

@riverpod
class ContactSearch extends _$ContactSearch {
  @override
  FutureOr<List<UserProfile>> build(String query) async {
    if (query.isEmpty) return [];
    return _searchUsers(query);
  }

  Future<List<UserProfile>> _searchUsers(String query) async {
    final repository = ref.read(contactsRepositoryProvider);
    return repository.searchUsers(query);
  }

  Future<void> addContact(String userId) async {
    try {
      final repository = ref.read(contactsRepositoryProvider);
      await repository.addContact(userId);
    } catch (e) {
      rethrow;
    }
  }
}
