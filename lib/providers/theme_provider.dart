import 'package:flutter/material.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/theme.dart';

class ThemeProvider extends ChangeNotifier {
  // Get important user defined services for fetching/altering user data
  final _userService = UserService();

  ThemeMode _themeMode = ThemeMode.light;
  Color _primaryColor = Colors.green;

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;

  void toggleTheme(bool isDark, {bool updateDatabase = true}) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    if (updateDatabase) updateTheme();
  }

  void toggleSystemTheme(bool isSystem, {bool updateDatabase = true}) {
    _themeMode = isSystem ? ThemeMode.system : ThemeMode.light;
    notifyListeners();

    if (updateDatabase) updateTheme();
  }

  Future<void> updateTheme() async {
    await _userService.updateUserData('theme_mode', _themeMode.toString());
  }

  Future<void> updateColor() async {
    await _userService.updateUserData('theme_color', _primaryColor.toARGB32());
  }

  void setPrimaryColor(Color color, {bool updateDatabase = true}) {
    _primaryColor = color;
    notifyListeners();

    if (updateDatabase) updateColor();
  }

  ThemeData get themeData {
    return _themeMode == ThemeMode.dark
        ? darkTheme(_primaryColor)
        : lightTheme(_primaryColor);
  }

  // Initialization function to get the user theme, if no user is logged in,
  // it sets the theme to the device theme
  Future<void> loadTheme() async {
    final userData = await _userService.getUserData();

    if (userData.isEmpty) {
      toggleSystemTheme(true, updateDatabase: false);
      notifyListeners();
      return;
    }

    // Set theme
    switch (userData["theme_mode"]) {
      case 'ThemeMode.dark':
        toggleTheme(true, updateDatabase: false);
        break;
      case 'ThemeMode.light':
        toggleTheme(false, updateDatabase: false);
        break;
      case 'ThemeMode.system':
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
    notifyListeners();
  }
}
