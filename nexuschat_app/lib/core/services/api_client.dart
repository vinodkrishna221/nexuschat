import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:nexuschat_app/core/services/token_storage_service.dart';
import 'package:nexuschat_app/core/services/logging_interceptor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

@Riverpod(keepAlive: true)
Dio apiClient(ApiClientRef ref) {
  final tokenStorage = ref.watch(tokenStorageServiceProvider);

  String baseUrl = 'http://localhost:3000/api/v1';
  if (!kIsWeb) {
    if (Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:3000/api/v1';
    }
  }
  debugPrint('🔗 API baseUrl: $baseUrl');

  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  dio.interceptors.add(LoggingInterceptor());
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await tokenStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (DioException e, handler) async {
       // TODO: Implement Token Refresh Logic here if status is 401
       return handler.next(e);
    },
  ));

  return dio;
}
