import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

/// Service to monitor network connectivity status
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamController<bool>? _controller;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;

  /// Stream that emits true when online, false when offline
  Stream<bool> get onConnectivityChanged {
    _controller ??= StreamController<bool>.broadcast(
      onListen: _startListening,
      onCancel: _stopListening,
    );
    return _controller!.stream;
  }

  /// Current connectivity status
  bool get isOnline => _isOnline;

  void _startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final newStatus = _checkConnectivity(results);
      if (newStatus != _isOnline) {
        _isOnline = newStatus;
        _controller?.add(_isOnline);
        debugPrint('📶 Connectivity changed: ${_isOnline ? "ONLINE" : "OFFLINE"}');
      }
    });

    // Check initial status
    checkConnectivity();
  }

  void _stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  bool _checkConnectivity(List<ConnectivityResult> results) {
    // Consider online if any connection type except none
    return results.isNotEmpty && 
           !results.every((r) => r == ConnectivityResult.none);
  }

  /// Manually check current connectivity
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _isOnline = _checkConnectivity(results);
      _controller?.add(_isOnline);
      return _isOnline;
    } catch (e) {
      debugPrint('⚠️ Error checking connectivity: $e');
      return true; // Assume online on error
    }
  }

  void dispose() {
    _stopListening();
    _controller?.close();
    _controller = null;
  }
}

/// Provider for the ConnectivityService singleton
@Riverpod(keepAlive: true)
ConnectivityService connectivityService(ConnectivityServiceRef ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
}

/// Provider that tracks current online/offline status reactively
@Riverpod(keepAlive: true)
Stream<bool> connectivityStatus(ConnectivityStatusRef ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onConnectivityChanged;
}

/// Provider for current connectivity state (synchronous read)
@riverpod
bool isOnline(IsOnlineRef ref) {
  final service = ref.watch(connectivityServiceProvider);
  // Also watch the stream to stay reactive
  ref.watch(connectivityStatusProvider);
  return service.isOnline;
}
