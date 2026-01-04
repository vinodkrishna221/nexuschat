import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexuschat_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nexuschat_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:nexuschat_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:nexuschat_app/features/settings/presentation/widgets/settings_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Profile Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 0,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                ),
                child: InkWell(
                  onTap: () => context.push('/profile'),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: profile.whenOrNull(
                            data: (user) => user.avatar != null ? NetworkImage(user.avatar!) : null,
                          ),
                          child: profile.whenOrNull(
                            data: (user) => user.avatar == null ? Text(user.username[0].toUpperCase()) : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.when(
                                  data: (user) => user.displayName ?? user.username,
                                  loading: () => 'Loading...',
                                  error: (_, __) => 'User',
                                ),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                profile.when(
                                  data: (user) => '@${user.username}',
                                  loading: () => '...',
                                  error: (_, __) => '',
                                ),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            // Preferences
             _buildSectionHeader(context, 'PREFERENCES'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                 border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.dark_mode,
                    title: 'Dark Mode',
                    trailing: Switch(
                      value: settings.themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        ref.read(settingsProvider.notifier).toggleTheme(value);
                      },
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  SettingsTile(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    trailing: Switch(
                      value: settings.notificationsEnabled,
                      onChanged: (value) {
                         ref.read(settingsProvider.notifier).updateNotifications(value);
                      },
                    ),
                  ),
                   const Divider(height: 1, indent: 56),
                  SettingsTile(
                    icon: Icons.volume_up,
                    title: 'Sounds',
                    trailing: Switch(
                      value: settings.soundEnabled,
                      onChanged: (value) {
                         ref.read(settingsProvider.notifier).updateSound(value);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
             _buildSectionHeader(context, 'PRIVACY'),
             Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                 border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.block,
                    title: 'Blocked Users',
                    trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                    onTap: () {
                      // Navigate to blocked users
                    },
                  ),
                ],
              ),
            ),
             
             const SizedBox(height: 24),
             _buildSectionHeader(context, 'ABOUT'),
             Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                 border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
               child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.info,
                    title: 'About NexusChat',
                    trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                    onTap: () {
                      context.push('/settings/about');
                    },
                  ),
                ],
              ),
             ),

            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Log Out'),
                        content: const Text('Are you sure you want to log out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('CANCEL'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ref.read(authProvider.notifier).logout();
                            },
                             style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('LOG OUT'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Log Out'),
                   style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
             const SizedBox(height: 16),
             Center(child: Text("Version 1.0.0", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
