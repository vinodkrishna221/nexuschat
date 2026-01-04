import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexuschat_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:nexuschat_app/features/profile/presentation/widgets/avatar_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  late TextEditingController _statusController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _bioController = TextEditingController();
    _statusController = TextEditingController();
    _emailController = TextEditingController();
    
    // Initialize with current data
    final profile = ref.read(profileProvider).value;
    if (profile != null) {
      _displayNameController.text = profile.displayName ?? profile.username;
      _bioController.text = profile.bio ?? '';
      _statusController.text = profile.status ?? '';
      _emailController.text = profile.email ?? '';
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _statusController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    try {
      await ref.read(profileProvider.notifier).updateProfile(
        displayName: _displayNameController.text,
        bio: _bioController.text,
        status: _statusController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final isLoading = profileState.isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        title: const Text('Edit Profile'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: isLoading ? null : _saveProfile,
            child: Text(
              'Save',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar Picker
            profileState.when(
              data: (profile) => Column(
                children: [
                  AvatarPicker(
                    currentAvatarUrl: profile.avatar,
                    isLoading: isLoading,
                    size: 100,
                    onImageSelected: (file) {
                      ref.read(profileProvider.notifier).updateAvatar(file);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      // Trigger avatar picker programmatically if needed
                      // Or just let user click the avatar
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: Theme.of(context).primaryColor.withOpacity(0.5),
                        ),
                      ),
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                    child: Text(
                      'Change Photo',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 32),

            // Form Fields
            _buildTextField(
              controller: _displayNameController,
              label: 'Display Name',
              hint: 'John Doe',
            ),
            const SizedBox(height: 20),
            
            // Username (Read-only)
            _buildTextField(
              controller: TextEditingController(text: ref.watch(profileProvider).value?.username ?? ''),
              label: 'Username',
              hint: '@johndoe',
              prefixText: '@',
              readOnly: true,
              helperText: 'This is how others find you.',
            ),
            const SizedBox(height: 20),

            _buildTextField(
              controller: _bioController,
              label: 'Bio',
              hint: 'Write something about yourself...',
              maxLines: 3,
              maxLength: 150,
            ),
            const SizedBox(height: 20),

            _buildTextField(
              controller: _statusController,
              label: 'Status',
              hint: 'Available ✨',
              icon: Icons.face,
            ),
            const SizedBox(height: 20),

            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'john@example.com',
              readOnly: true,
              icon: Icons.lock_outline,
              helperText: 'To change email, contact support.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    String? prefixText,
    bool readOnly = false,
    int maxLines = 1,
    int? maxLength,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                  letterSpacing: 1.0,
                ),
              ),
              if (maxLength != null)
                ValueListenableBuilder(
                  valueListenable: controller,
                  builder: (context, value, child) {
                    return Text(
                      '${value.text.length}/$maxLength',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: readOnly 
                ? Theme.of(context).cardColor.withOpacity(0.3) 
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            maxLines: maxLines,
            maxLength: maxLength,
            style: TextStyle(
              color: readOnly ? Colors.grey : Theme.of(context).textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon: icon != null ? Icon(icon, color: Theme.of(context).primaryColor) : null,
              prefixText: prefixText,
              prefixStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              isDense: true,
              counterText: '', // Hide default counter
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              helperText,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ],
    );
  }
}
