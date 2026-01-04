import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nexuschat_app/core/theme/app_colors.dart';

/// Full-screen error display for critical failures
class ErrorScreen extends StatelessWidget {
  final String title;
  final String? message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final IconData icon;
  final bool isLoading;

  const ErrorScreen({
    super.key,
    this.title = 'Something went wrong',
    this.message,
    this.buttonText = 'Try Again',
    this.onRetry,
    this.icon = Icons.error_outline,
    this.isLoading = false,
  });

  /// Factory for network errors
  factory ErrorScreen.network({
    VoidCallback? onRetry,
    bool isLoading = false,
  }) {
    return ErrorScreen(
      title: 'Connection Error',
      message: 'Please check your internet connection and try again.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
      isLoading: isLoading,
    );
  }

  /// Factory for server errors
  factory ErrorScreen.server({
    VoidCallback? onRetry,
    bool isLoading = false,
  }) {
    return ErrorScreen(
      title: 'Server Error',
      message: 'Our servers are having trouble. Please try again later.',
      icon: Icons.cloud_off,
      onRetry: onRetry,
      isLoading: isLoading,
    );
  }

  /// Factory for authentication errors
  factory ErrorScreen.auth({
    VoidCallback? onRetry,
    String buttonText = 'Sign In',
  }) {
    return ErrorScreen(
      title: 'Session Expired',
      message: 'Please sign in again to continue.',
      icon: Icons.lock_outline,
      buttonText: buttonText,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppColors.backgroundDarker,
                    AppColors.backgroundDark,
                  ]
                : [
                    Colors.grey[50]!,
                    Colors.grey[100]!,
                  ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error icon with gradient glow
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFF43F5E).withOpacity(0.15),
                        const Color(0xFFF97316).withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 56,
                    color: const Color(0xFFF43F5E),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(height: 32),

                // Title
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),

                // Message
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDark ? Colors.white60 : Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, end: 0),
                ],

                const SizedBox(height: 48),

                // Retry button
                if (onRetry != null)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: isLoading ? null : onRetry,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              buttonText!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  )
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline error widget for use within screens
class InlineError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool compact;

  const InlineError({
    super.key,
    required this.message,
    this.onRetry,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF43F5E).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF43F5E).withOpacity(0.2),
        ),
      ),
      child: compact
          ? Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFF43F5E),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (onRetry != null)
                  TextButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFF43F5E),
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Try Again'),
                  ),
                ],
              ],
            ),
    );
  }
}
