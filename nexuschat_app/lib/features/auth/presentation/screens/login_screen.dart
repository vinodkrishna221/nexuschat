import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nexuschat_app/core/theme/app_colors.dart';
import 'package:nexuschat_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nexuschat_app/features/auth/presentation/widgets/auth_button.dart';
import 'package:nexuschat_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:nexuschat_app/features/auth/presentation/widgets/social_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  String _parseErrorMessage(dynamic error) {
    final errorStr = error.toString();
    
    // Parse common error types into user-friendly messages
    if (errorStr.contains('Invalid credentials') || errorStr.contains('invalid')) {
      return 'Invalid email or password. Please try again.';
    }
    if (errorStr.contains('User not found') || errorStr.contains('not found')) {
      return 'No account found with this email. Please sign up.';
    }
    if (errorStr.contains('network') || errorStr.contains('connection') || errorStr.contains('SocketException')) {
      return 'Unable to connect. Please check your internet.';
    }
    if (errorStr.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    // Return the error as-is if it's already user-friendly
    if (errorStr.length < 100) {
      return errorStr;
    }
    
    return 'Login failed. Please try again.';
  }

  Future<void> _handleLogin() async {
    // Clear previous error
    setState(() => _errorMessage = null);
    
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      // Navigation is handled by auth state listener in main.dart
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _parseErrorMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Background Decoration Layers
          Positioned(
            bottom: -100,
            left: MediaQuery.of(context).size.width / 2 - 150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Text(
                          'Welcome Back',
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to continue',
                          style: TextStyle(
                            color: const Color(0xFFA1A1AA),
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Error Message Banner
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Colors.red, fontSize: 14),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() => _errorMessage = null),
                                  child: const Icon(Icons.close, color: Colors.red, size: 18),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Form Fields
                        AuthTextField(
                          controller: _emailController,
                          hintText: 'Email or username',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 20),
                        AuthTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          validator: _validatePassword,
                        ),

                        const SizedBox(height: 12),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              context.push('/forgot-password');
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF22D3EE),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text('Forgot password?'),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Login Button
                        AuthButton(
                          text: 'Log In',
                          onPressed: _handleLogin,
                          isLoading: _isLoading,
                        ),

                        const SizedBox(height: 32),

                        // Divider
                        Row(
                          children: [
                            const Expanded(child: Divider(color: Color(0xFF2d2839))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Or continue with',
                                style: TextStyle(color: const Color(0xFFA1A1AA), fontSize: 14),
                              ),
                            ),
                            const Expanded(child: Divider(color: Color(0xFF2d2839))),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Social Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SocialButton(iconPath: '', onPressed: () {}), // Apple
                            const SizedBox(width: 24),
                            SocialButton(iconPath: '', onPressed: () {}), // Google
                            const SizedBox(width: 24),
                            SocialButton(iconPath: '', onPressed: () {}), // Facebook
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(color: const Color(0xFFA1A1AA)),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.push('/signup');
                              },
                              child: Text(
                                'Sign up',
                                style: TextStyle(
                                  color: const Color(0xFF22D3EE),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
