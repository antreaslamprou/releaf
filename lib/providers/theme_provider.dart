import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/theme.dart';

class ThemeProvider extends ChangeNotifier {
  // Get important user defined services for fetching/altering user data
  final _userService = UserService();

  // Default theme is light
  ThemeData themeData = lightMode;
  bool isSystem = false;

  // Returns the corresponding theme to the device theme
  ThemeData getSystemTheme() {
    return SchedulerBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark
        ? darkMode
        : lightMode;
  }

  String getSystemThemeString() {
    return SchedulerBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark
        ? 'dark'
        : 'light';
  }

  // Initialization function to get the user theme, if no user is logged in,
  // it sets the theme to the device theme
  Future<void> loadTheme() async {
    final userData = await _userService.getUserData();

    if (userData.isEmpty) {
      themeData = getSystemTheme();
      isSystem = true;
      notifyListeners();
      return;
    }

    switch (userData["theme_mode"]) {
      case 'dark':
        themeData = darkMode;
        break;
      case 'light':
        themeData = lightMode;
        break;
      case 'system':
        themeData = getSystemTheme();
        isSystem = true;
    }

    notifyListeners();
  }

  // Toggles between light and dark theme and updates the user settings
  void toggleTheme() async {
    themeData = (themeData == lightMode) ? darkMode : lightMode;

    final bool isDark = themeData == darkMode;
    await _userService.updateUserData('theme_mode', isDark);

    notifyListeners();
  }

  // Set or unset theme mode as system and updates the user settings
  void toogleSystemTheme({bool set = true}) async {
    themeData = getSystemTheme();
    isSystem = set;
    await _userService.updateUserData(
      'theme_mode',
      set ? 'system' : getSystemThemeString(),
    );

    notifyListeners();
  }

  // Resets the theme to the device theme
  void reset() {
    themeData = getSystemTheme();
    notifyListeners();
  }
}
