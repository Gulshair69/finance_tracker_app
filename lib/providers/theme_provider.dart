import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { light, darkBlue }

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.light;
  static const String _themeKey = 'app_theme';

  AppTheme get currentTheme => _currentTheme;
  bool get isDarkBlue => _currentTheme == AppTheme.darkBlue;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      _currentTheme = AppTheme.values[themeIndex];
      notifyListeners();
    } catch (e) {
      // Default to light theme if error
      _currentTheme = AppTheme.light;
    }
  }

  Future<void> toggleTheme() async {
    _currentTheme = _currentTheme == AppTheme.light
        ? AppTheme.darkBlue
        : AppTheme.light;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, _currentTheme.index);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> setTheme(AppTheme theme) async {
    if (_currentTheme != theme) {
      _currentTheme = theme;
      notifyListeners();

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_themeKey, _currentTheme.index);
      } catch (e) {
        // Handle error silently
      }
    }
  }
}
