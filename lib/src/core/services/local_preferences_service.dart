import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_models.dart';

class LocalPreferencesService {
  static const _themeModeKey = 'scene_link_theme_mode';
  static const _textScaleKey = 'scene_link_text_scale';
  static const _highContrastKey = 'scene_link_high_contrast';
  static const _screenReaderKey = 'scene_link_screen_reader';
  static const _reducedMotionKey = 'scene_link_reduced_motion';

  Future<AccessibilitySettings> loadAccessibilitySettings() async {
    final prefs = await SharedPreferences.getInstance();
    return AccessibilitySettings(
      textScaleFactor: prefs.getDouble(_textScaleKey) ?? 1.0,
      highContrast: prefs.getBool(_highContrastKey) ?? false,
      screenReaderFriendly: prefs.getBool(_screenReaderKey) ?? true,
      reducedMotion: prefs.getBool(_reducedMotionKey) ?? false,
    );
  }

  Future<void> saveAccessibilitySettings(AccessibilitySettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, settings.textScaleFactor);
    await prefs.setBool(_highContrastKey, settings.highContrast);
    await prefs.setBool(_screenReaderKey, settings.screenReaderFriendly);
    await prefs.setBool(_reducedMotionKey, settings.reducedMotion);
  }

  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_themeModeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, themeMode.name);
  }
}