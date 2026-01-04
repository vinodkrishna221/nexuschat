import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nexuschat_app/core/theme/app_theme.dart';
import 'package:nexuschat_app/core/services/toast_service.dart';
import 'package:nexuschat_app/core/services/message_queue_service.dart';
import 'package:nexuschat_app/features/splash/presentation/splash_screen.dart';
import 'package:nexuschat_app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:nexuschat_app/features/auth/presentation/screens/login_screen.dart';
import 'package:nexuschat_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:nexuschat_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:nexuschat_app/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:nexuschat_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nexuschat_app/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:nexuschat_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:nexuschat_app/features/chat/domain/models/chat_model.dart';
import 'package:nexuschat_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:nexuschat_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:nexuschat_app/features/contacts/presentation/screens/contacts_screen.dart';
import 'package:nexuschat_app/features/contacts/presentation/screens/add_contact_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexuschat_app/features/settings/data/repositories/settings_repository.dart';
import 'package:nexuschat_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:nexuschat_app/features/settings/presentation/screens/about_screen.dart';
import 'package:nexuschat_app/features/settings/presentation/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Initialize message queue service
  final messageQueue = MessageQueueService();
  await messageQueue.init();
  
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(
          SettingsRepository(sharedPreferences),
        ),
        messageQueueServiceProvider.overrideWithValue(messageQueue),
      ],
      child: const NexusChatApp(),
    ),
  );
}

class NexusChatApp extends ConsumerWidget {
  const NexusChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'NexusChat',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: toast.messengerKey,
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authStatus = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreenWrapper(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return ResetPasswordScreen(token: token);
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) {
          final chatId = state.pathParameters['id']!;
          final chat = state.extra as ChatModel?;
          return ChatScreen(chatId: chatId, chat: chat);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => const EditProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/contacts',
        builder: (context, state) => const ContactsScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddContactScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'about',
            builder: (context, state) => const AboutScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isAuth = authStatus == AuthStatus.authenticated;
      final isUnAuth = authStatus == AuthStatus.unauthenticated;
      final isSplashing = state.uri.toString() == '/';
      final isLoggingIn = state.uri.toString() == '/login';
      final isSigningUp = state.uri.toString() == '/signup';
      final isOnboarding = state.uri.toString() == '/onboarding';
      final isForgot = state.uri.toString() == '/forgot-password';

      // If initial/loading, stay on splash (or handled by wrapper)
      if (authStatus == AuthStatus.initial || authStatus == AuthStatus.loading) {
        return null;
      }

      if (isAuth) {
        // If authenticated but on auth screens, go to home
        if (isLoggingIn || isSigningUp || isOnboarding || isForgot || isSplashing) {
          return '/home';
        }
      } else if (isUnAuth) {
        // If unauthenticated, allow auth screens, otherwise go to onboarding
        if (isSplashing) {
           return '/onboarding';
        }
        // stay where we are if it's an allowed public route
      }
      
      return null;
    },
  );
});

class SplashScreenWrapper extends ConsumerStatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  ConsumerState<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends ConsumerState<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    // Check auth status on app start
    // Use addPostFrameCallback to ensure provider is ready if needed, 
    // but reading in initState is usually safe for methods.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
