import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/theme.dart';

class ThemeProvider extends ChangeNotifier {
  final userService = UserService();

  ThemeData themeData = lightMode;

  void toggleTheme() async {
    themeData = (themeData == lightMode) ? darkMode : lightMode;

    final bool isDark = themeData == darkMode;
    await userService.updateUserData('is_dark_mode', isDark);

    notifyListeners();
  }

  ThemeData getSystemTheme() {
    return SchedulerBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark
        ? darkMode
        : lightMode;
  }

  Future<void> loadTheme() async {
    final userData = await userService.getUserData();
    if (userData.isEmpty) {
      themeData = getSystemTheme();
      notifyListeners();
      return;
    }
    final bool isDark = userData["is_dark_mode"];

    themeData = isDark ? darkMode : lightMode;

    notifyListeners();
  }

  void reset() {
    themeData = getSystemTheme();
    notifyListeners();
  }
}
