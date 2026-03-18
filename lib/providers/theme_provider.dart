import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/storage/hive_keys.dart';

part 'theme_provider.g.dart';

const _themeModeKey = 'theme_mode';

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    final box = Hive.box<dynamic>(HiveKeys.userPrefsBox);
    final stored = box.get(_themeModeKey, defaultValue: 'system') as String;
    return _fromString(stored);
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    final box = Hive.box<dynamic>(HiveKeys.userPrefsBox);
    box.put(_themeModeKey, _toString(mode));
  }

  static ThemeMode _fromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
