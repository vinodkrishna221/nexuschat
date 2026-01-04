import 'package:nexuschat_app/core/services/token_storage_service.dart';
import 'package:nexuschat_app/core/services/socket_service.dart';
import 'package:nexuschat_app/features/auth/data/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  AuthStatus build() {
    return AuthStatus.initial;
  }

  Future<void> checkAuthStatus() async {
    state = AuthStatus.loading;
    final token = await ref.read(tokenStorageServiceProvider).getAccessToken();
    if (token != null) {
      state = AuthStatus.authenticated;
      ref.read(socketServiceProvider).connect(token);
    } else {
      state = AuthStatus.unauthenticated;
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthStatus.loading;
    try {
      final response = await ref.read(authRepositoryProvider).login(email, password);
      await _saveTokens(response);
      state = AuthStatus.authenticated;
      
      // Connect to socket
      final accessToken = response['accessToken'];
      if (accessToken != null) {
        ref.read(socketServiceProvider).connect(accessToken);
      }
    } catch (e) {
      state = AuthStatus.error;
      rethrow;
    }
  }

  Future<void> register(String email, String username, String password) async {
    state = AuthStatus.loading;
    try {
      final response = await ref.read(authRepositoryProvider).register(email, username, password);
      if (response.containsKey('accessToken')) {
         await _saveTokens(response);
         state = AuthStatus.authenticated;
         
         // Connect to socket
         final accessToken = response['accessToken'];
         if (accessToken != null) {
           ref.read(socketServiceProvider).connect(accessToken);
         }
      } else {
         if (response['accessToken'] != null) {
            await _saveTokens(response);
            state = AuthStatus.authenticated;
            
            // Connect to socket
            final accessToken = response['accessToken'];
            if (accessToken != null) {
              ref.read(socketServiceProvider).connect(accessToken);
            }
         } else {
             state = AuthStatus.unauthenticated;
         }
      }
    } catch (e) {
      state = AuthStatus.error;
      rethrow;
    }
  }

  Future<void> logout() async {
    await ref.read(tokenStorageServiceProvider).clearTokens();
    ref.read(socketServiceProvider).disconnect();
    state = AuthStatus.unauthenticated;
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final accessToken = data['accessToken'];
    final refreshToken = data['refreshToken'];
    if (accessToken != null && refreshToken != null) {
      await ref.read(tokenStorageServiceProvider).saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
    }
  }

  Future<void> forgotPassword(String email) async {
    await ref.read(authRepositoryProvider).forgotPassword(email);
  }

  Future<void> resetPassword(String token, String newPassword) async {
    await ref.read(authRepositoryProvider).resetPassword(token, newPassword);
  }
}
