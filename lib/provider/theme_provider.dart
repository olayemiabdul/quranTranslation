import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier with ChangeNotifier {
  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.dark);

  ThemeNotifier() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? true;
    themeModeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = themeModeNotifier.value == ThemeMode.dark;
    themeModeNotifier.value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await prefs.setBool('isDarkMode', !isDarkMode);
    notifyListeners();  // Notify widgets that theme has changed
  }
}
