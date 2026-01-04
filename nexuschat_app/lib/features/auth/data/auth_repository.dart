import 'package:dio/dio.dart';
import 'package:nexuschat_app/core/services/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(ref.watch(apiClientProvider));
}

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      // Backend returns { success: true, data: { accessToken, refreshToken, user } }
      return response.data['data'] ?? response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Login failed';
    }
  }

  Future<Map<String, dynamic>> register(String email, String username, String password) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'username': username,
        'password': password,
        'displayName': username, // Default display name
      });
      // Backend returns { success: true, data: { accessToken, refreshToken, user } }
      return response.data['data'] ?? response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Registration failed';
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post('/auth/forgot-password', data: {
        'email': email,
      });
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to send reset email';
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _dio.post('/auth/reset-password', data: {
        'token': token,
        'password': newPassword,
      });
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to reset password';
    }
  }
}
