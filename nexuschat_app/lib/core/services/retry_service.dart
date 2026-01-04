import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// Configuration for retry behavior
class RetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final double multiplier;
  final bool Function(Exception)? shouldRetry;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.multiplier = 2.0,
    this.shouldRetry,
  });

  static const RetryConfig defaultConfig = RetryConfig();

  /// Config optimized for message sending
  static const RetryConfig messageConfig = RetryConfig(
    maxAttempts: 5,
    initialDelay: Duration(seconds: 1),
    maxDelay: Duration(seconds: 30),
    multiplier: 2.0,
  );

  /// Config for quick retries (e.g., connectivity checks)
  static const RetryConfig quickConfig = RetryConfig(
    maxAttempts: 3,
    initialDelay: Duration(milliseconds: 500),
    maxDelay: Duration(seconds: 5),
    multiplier: 1.5,
  );
}

/// Result of a retry operation
class RetryResult<T> {
  final T? value;
  final Exception? error;
  final int attempts;
  final bool success;

  const RetryResult._({
    this.value,
    this.error,
    required this.attempts,
    required this.success,
  });

  factory RetryResult.success(T value, int attempts) {
    return RetryResult._(value: value, attempts: attempts, success: true);
  }

  factory RetryResult.failure(Exception error, int attempts) {
    return RetryResult._(error: error, attempts: attempts, success: false);
  }
}

/// Service for executing operations with exponential backoff retry
class RetryService {
  /// Execute an operation with retry logic
  /// 
  /// [operation] - The async function to execute
  /// [config] - Retry configuration (uses default if not provided)
  /// [onRetry] - Optional callback called before each retry
  Future<RetryResult<T>> execute<T>(
    Future<T> Function() operation, {
    RetryConfig config = RetryConfig.defaultConfig,
    void Function(int attempt, Duration delay, Exception error)? onRetry,
  }) async {
    int attempt = 0;
    Duration currentDelay = config.initialDelay;
    Exception? lastError;

    while (attempt < config.maxAttempts) {
      attempt++;
      
      try {
        final result = await operation();
        debugPrint('✅ Operation succeeded on attempt $attempt');
        return RetryResult.success(result, attempt);
      } on Exception catch (e) {
        lastError = e;
        
        // Check if we should retry this type of error
        if (config.shouldRetry != null && !config.shouldRetry!(e)) {
          debugPrint('🚫 Error not retryable: $e');
          return RetryResult.failure(e, attempt);
        }

        if (attempt < config.maxAttempts) {
          // Add some jitter to prevent thundering herd
          final jitter = Duration(
            milliseconds: Random().nextInt(currentDelay.inMilliseconds ~/ 4),
          );
          final delayWithJitter = currentDelay + jitter;
          
          debugPrint('⏳ Retry $attempt/${config.maxAttempts} in ${delayWithJitter.inMilliseconds}ms - Error: $e');
          
          onRetry?.call(attempt, delayWithJitter, e);
          
          await Future.delayed(delayWithJitter);
          
          // Calculate next delay with exponential backoff
          currentDelay = Duration(
            milliseconds: min(
              (currentDelay.inMilliseconds * config.multiplier).toInt(),
              config.maxDelay.inMilliseconds,
            ),
          );
        }
      }
    }

    debugPrint('❌ All ${config.maxAttempts} retry attempts failed');
    return RetryResult.failure(lastError ?? Exception('Unknown error'), attempt);
  }

  /// Execute operation with retry, throwing on final failure
  Future<T> executeOrThrow<T>(
    Future<T> Function() operation, {
    RetryConfig config = RetryConfig.defaultConfig,
    void Function(int attempt, Duration delay, Exception error)? onRetry,
  }) async {
    final result = await execute(operation, config: config, onRetry: onRetry);
    
    if (result.success) {
      return result.value as T;
    } else {
      throw result.error!;
    }
  }
}

/// Global retry service instance
final retryService = RetryService();
