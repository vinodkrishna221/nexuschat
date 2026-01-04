import 'package:flutter/material.dart';
import 'package:nexuschat_app/features/settings/data/repositories/settings_repository.dart';
import 'package:nexuschat_app/features/settings/domain/models/app_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_provider.g.dart';

@riverpod
class Settings extends _$Settings {
  @override
  AppSettings build() {
    final repository = ref.read(settingsRepositoryProvider);
    return repository.getSettings();
  }

  Future<void> toggleTheme(bool isDark) async {
    final repository = ref.read(settingsRepositoryProvider);
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    final newSettings = state.copyWith(themeMode: newMode);
    
    await repository.saveSettings(newSettings);
    state = newSettings;
  }

  Future<void> updateNotifications(bool enabled) async {
    final repository = ref.read(settingsRepositoryProvider);
    final newSettings = state.copyWith(notificationsEnabled: enabled);
    
    await repository.saveSettings(newSettings);
    state = newSettings;
  }

  Future<void> updateSound(bool enabled) async {
    final repository = ref.read(settingsRepositoryProvider);
    final newSettings = state.copyWith(soundEnabled: enabled);
    
    await repository.saveSettings(newSettings);
    state = newSettings;
  }
}
