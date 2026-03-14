import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:releaf/services/user_service.dart';

class ThemeProvider extends ChangeNotifier {
  // Get important user defined services for fetching/altering user data
  final _userService = UserService();

  ThemeMode _themeMode = ThemeMode.system;
  Brightness _brightness = Brightness.light;
  Color _primaryColor = Colors.green;

  ThemeMode get themeMode => _themeMode;
  Brightness get brightness => _brightness;
  Color get primaryColor => _primaryColor;

  void toggleTheme(bool isDark, {bool updateDatabase = true}) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _brightness = isDark ? Brightness.dark : Brightness.light;
    notifyListeners();

    if (updateDatabase) updateTheme();
  }

  void toggleSystemTheme(bool isSystem, {bool updateDatabase = true}) {
    if (isSystem) {
      _themeMode = ThemeMode.system;
      _brightness = PlatformDispatcher.instance.platformBrightness;
    } else {
      _brightness = PlatformDispatcher.instance.platformBrightness;
      _themeMode = brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light;
    }
    notifyListeners();

    if (updateDatabase) updateTheme();
  }

  Future<void> updateTheme() async {
    await _userService.updateUserData('theme_mode', _themeMode.name);
  }

  Future<void> updateColor() async {
    await _userService.updateUserData('theme_color', _primaryColor.toARGB32());
  }

  void setPrimaryColor(Color color, {bool updateDatabase = true}) {
    _primaryColor = color;
    notifyListeners();

    if (updateDatabase) updateColor();
  }

  // Initialization function to get the user theme, if no user is logged in,
  // it sets the theme to the device theme
  Future<void> loadTheme() async {
    final userData = await _userService.getUserData();

    // Listen to system brightness changes
    PlatformDispatcher.instance.onPlatformBrightnessChanged = () {
      if (_themeMode == ThemeMode.system) {
        _brightness = PlatformDispatcher.instance.platformBrightness;
        notifyListeners();
      } else {}
    };

    if (userData.isEmpty) {
      toggleSystemTheme(true, updateDatabase: false);
      return;
    }

    // Set theme
    switch (userData["theme_mode"]) {
      case 'dark':
        toggleTheme(true, updateDatabase: false);
        break;
      case 'light':
        toggleTheme(false, updateDatabase: false);
        break;
      case 'system':
        toggleSystemTheme(true, updateDatabase: false);
    }

    // Set primary color
    final int color = userData["theme_color"];
    _primaryColor = Color(color);

    notifyListeners();
  }

  // Resets the theme to the device theme
  void reset() {
    toggleSystemTheme(true);

    // Delete theme listener
    PlatformDispatcher.instance.onPlatformBrightnessChanged = null;

    notifyListeners();
  }
}
