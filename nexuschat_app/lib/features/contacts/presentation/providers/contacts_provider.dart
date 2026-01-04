import 'package:nexuschat_app/features/contacts/data/repositories/contacts_repository.dart';
import 'package:nexuschat_app/features/contacts/domain/models/contact.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'contacts_provider.g.dart';

@riverpod
class Contacts extends _$Contacts {
  @override
  FutureOr<List<Contact>> build() async {
    return _fetchContacts();
  }

  Future<List<Contact>> _fetchContacts() async {
    final repository = ref.read(contactsRepositoryProvider);
    return repository.getContacts();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchContacts());
  }

  Future<void> removeContact(String contactId) async {
    try {
      final repository = ref.read(contactsRepositoryProvider);
      await repository.removeContact(contactId);
      // Optimistic update or refresh
      ref.invalidateSelf();
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  Future<void>  blockUser(String userId) async {
      try {
        final repository = ref.read(contactsRepositoryProvider);
        await repository.blockUser(userId);
         ref.invalidateSelf();
      } catch (e) {
        rethrow;
      }
  }
}
