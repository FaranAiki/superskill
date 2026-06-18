import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettings {
  final ThemeMode themeMode;
  final double fontSizeMultiplier;
  final String fontFamily;

  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.fontSizeMultiplier = 1.0,
    this.fontFamily = 'Inter',
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    double? fontSizeMultiplier,
    String? fontFamily,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      fontSizeMultiplier: fontSizeMultiplier ?? this.fontSizeMultiplier,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings());

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void setFontSize(double multiplier) {
    state = state.copyWith(fontSizeMultiplier: multiplier);
  }

  void setFontFamily(String family) {
    state = state.copyWith(fontFamily: family);
  }
}

final settingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier();
});
