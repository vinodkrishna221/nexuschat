import 'package:dio/dio.dart';
import 'package:nexuschat_app/core/services/api_client.dart';
import 'package:nexuschat_app/features/contacts/domain/models/contact.dart';
import 'package:nexuschat_app/features/profile/domain/models/user_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'contacts_repository.g.dart';

@Riverpod(keepAlive: true)
ContactsRepository contactsRepository(ContactsRepositoryRef ref) {
  return ContactsRepository(ref.watch(apiClientProvider));
}

class ContactsRepository {
  final Dio _dio;

  ContactsRepository(this._dio);

  Future<List<Contact>> getContacts() async {
    try {
      final response = await _dio.get('/contacts');
      final data = response.data['data'] as List;
      return data.map((e) => Contact.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch contacts';
    }
  }

  Future<List<UserProfile>> searchUsers(String query) async {
    try {
      final response = await _dio.get('/users/search', queryParameters: {'q': query});
      final data = response.data['data'] as List;
      return data.map((e) => UserProfile.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to search users';
    }
  }

  Future<void> addContact(String userId) async {
    try {
      await _dio.post('/contacts/add', data: {'userId': userId});
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to add contact';
    }
  }

  Future<void> removeContact(String contactId) async {
    try {
      await _dio.delete('/contacts/$contactId');
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to remove contact';
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      await _dio.post('/contacts/block', data: {'userId': userId});
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to block user';
    }
  }
}
