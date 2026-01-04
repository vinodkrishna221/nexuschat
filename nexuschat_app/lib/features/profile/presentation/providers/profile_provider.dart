import 'dart:io';
import 'package:nexuschat_app/features/profile/data/repositories/profile_repository.dart';
import 'package:nexuschat_app/features/profile/domain/models/user_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_provider.g.dart';

@riverpod
class Profile extends _$Profile {
  @override
  FutureOr<UserProfile> build() async {
    return _fetchProfile();
  }

  Future<UserProfile> _fetchProfile() async {
    final repository = ref.read(profileRepositoryProvider);
    return repository.getProfile();
  }

  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? status,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(profileRepositoryProvider);
      final updatedProfile = await repository.updateProfile(
        displayName: displayName,
        bio: bio,
        status: status,
      );
      state = AsyncValue.data(updatedProfile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateAvatar(File imageFile) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(profileRepositoryProvider);
      final updatedProfile = await repository.uploadAvatar(imageFile);
      state = AsyncValue.data(updatedProfile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
