import 'dart:convert';
import 'package:flutter/material.dart'; // For ThemeMode enum
import 'package:nexuschat_app/features/settings/domain/models/app_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_repository.g.dart';

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(SettingsRepositoryRef ref) {
  throw UnimplementedError('Initialize this provider in main.dart');
}

class SettingsRepository {
  final SharedPreferences _prefs;
  static const _key = 'app_settings';

  SettingsRepository(this._prefs);

  AppSettings getSettings() {
    final jsonString = _prefs.getString(_key);
    if (jsonString != null) {
      try {
        return AppSettings.fromJson(jsonDecode(jsonString));
      } catch (e) {
        return const AppSettings();
      }
    }
    return const AppSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setString(_key, jsonEncode(settings.toJson()));
  }
}
