import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/theme.dart';

class ThemeProvider extends ChangeNotifier {
  // Get important user defined services for fetching/altering user data
  final _userService = UserService();

  // Default theme is light
  ThemeData themeData = lightMode;

  // Returns the corresponding theme to the device theme
  ThemeData getSystemTheme() {
    return SchedulerBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark
        ? darkMode
        : lightMode;
  }

  // Initialization function to get the user theme, if no user is logged in,
  // it sets the theme to the device theme
  Future<void> loadTheme() async {
    final userData = await _userService.getUserData();

    if (userData.isEmpty) {
      themeData = getSystemTheme();
      notifyListeners();
      return;
    }
    final bool isDark = userData["is_dark_mode"];

    themeData = isDark ? darkMode : lightMode;

    notifyListeners();
  }

  // Toggles between light and dark theme, updates the user settings aswell
  void toggleTheme() async {
    themeData = (themeData == lightMode) ? darkMode : lightMode;

    final bool isDark = themeData == darkMode;
    await _userService.updateUserData('is_dark_mode', isDark);

    notifyListeners();
  }

  // Resets the theme to the device theme
  void reset() {
    themeData = getSystemTheme();
    notifyListeners();
  }
}
