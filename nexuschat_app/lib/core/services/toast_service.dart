import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Toast types for different message styles
enum ToastType {
  success,
  error,
  warning,
  info,
}

/// Configuration for toast display
class ToastConfig {
  final String message;
  final ToastType type;
  final Duration duration;
  final SnackBarAction? action;

  const ToastConfig({
    required this.message,
    this.type = ToastType.info,
    this.duration = const Duration(seconds: 4),
    this.action,
  });
}

/// Global toast service for showing snackbar notifications
class ToastService {
  static final ToastService _instance = ToastService._internal();
  factory ToastService() => _instance;
  ToastService._internal();

  final GlobalKey<ScaffoldMessengerState> messengerKey = 
      GlobalKey<ScaffoldMessengerState>();

  /// Show a toast message
  void show(ToastConfig config) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;

    // Clear any existing snackbars
    messenger.clearSnackBars();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            _getIcon(config.type),
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              config.message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: _getColor(config.type),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      duration: config.duration,
      action: config.action,
    );

    messenger.showSnackBar(snackBar);
  }

  /// Show a success toast
  void success(String message, {SnackBarAction? action}) {
    show(ToastConfig(
      message: message,
      type: ToastType.success,
      action: action,
    ));
  }

  /// Show an error toast
  void error(String message, {SnackBarAction? action}) {
    show(ToastConfig(
      message: message,
      type: ToastType.error,
      action: action,
    ));
  }

  /// Show a warning toast
  void warning(String message, {SnackBarAction? action}) {
    show(ToastConfig(
      message: message,
      type: ToastType.warning,
      action: action,
    ));
  }

  /// Show an info toast
  void info(String message, {SnackBarAction? action}) {
    show(ToastConfig(
      message: message,
      type: ToastType.info,
      action: action,
    ));
  }

  IconData _getIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.warning:
        return Icons.warning_amber_outlined;
      case ToastType.info:
        return Icons.info_outline;
    }
  }

  Color _getColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return const Color(0xFF10B981); // Semantic success
      case ToastType.error:
        return const Color(0xFFF43F5E); // Semantic error  
      case ToastType.warning:
        return const Color(0xFFF59E0B); // Semantic warning
      case ToastType.info:
        return const Color(0xFF0EA5E9); // Semantic info
    }
  }
}

/// Global toast service instance
final toast = ToastService();

/// Provider for toast service
final toastServiceProvider = Provider<ToastService>((ref) {
  return ToastService();
});
