import 'dart:io';
import 'package:dio/dio.dart';
import 'package:nexuschat_app/core/services/api_client.dart';
import 'package:nexuschat_app/features/profile/domain/models/user_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_repository.g.dart';

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return ProfileRepository(ref.watch(apiClientProvider));
}

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<UserProfile> getProfile() async {
    try {
      final response = await _dio.get('/users/me');
      return UserProfile.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch profile';
    }
  }

  Future<UserProfile> updateProfile({
    String? displayName,
    String? bio,
    String? status,
  }) async {
    try {
      final response = await _dio.patch('/users/me', data: {
        if (displayName != null) 'displayName': displayName,
        if (bio != null) 'bio': bio,
        if (status != null) 'status': status,
      });
      return UserProfile.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to update profile';
    }
  }

  Future<UserProfile> uploadAvatar(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/users/me/avatar',
        data: formData,
      );
      
      // Response might contain the updated user or just the avatar URL
      // Check API spec or implementation. 
      // Based on user controller implementation:
      // res.status(200).json({ success: true, data: { avatar: url, ...user }, ... });
      return UserProfile.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to upload avatar';
    }
  }
}
