import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _defaultQuality = '720p';
  bool _useAnimations = true;

  ThemeMode get themeMode => _themeMode;
  String get defaultQuality => _defaultQuality;
  bool get useAnimations => _useAnimations;

  void toggleThemeMode() {
    // Cycle: system -> light -> dark -> system
    switch (_themeMode) {
      case ThemeMode.system:
        _themeMode = ThemeMode.light;
        break;
      case ThemeMode.light:
        _themeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setDefaultQuality(String quality) {
    _defaultQuality = quality;
    notifyListeners();
  }

  void setUseAnimations(bool value) {
    _useAnimations = value;
    notifyListeners();
  }
}
