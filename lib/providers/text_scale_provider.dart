import 'package:flutter/material.dart';
import 'package:releaf/services/user_service.dart';

class TextScaleProvider extends ChangeNotifier {
  // Get important user defined services for fetching/altering user data
  final _userService = UserService();

  // Default text scale is set to 1
  TextScaler textScale = TextScaler.linear(1);

  // Returns the scale as a double
  double get scaleFactor => textScale.scale(1.0);

  // Initialization function to get the user text scale, if no user is logged in,
  // it sets the text scale to 1
  Future<void> loadTextScale() async {
    final userData = await _userService.getUserData();

    if (userData.isEmpty) return;

    textScale = userData['text_scale'] != null
        ? TextScaler.linear(userData['text_scale'].toDouble())
        : TextScaler.linear(1);

    notifyListeners();
  }

  // Toogles the text scale between 1 and 1.2 (normal <-> large)
  Future<void> toogleTextScale() async {
    final value = scaleFactor == 1 ? 1.2 : 1.0;
    await _userService.updateUserData('text_scale', value);
    textScale = TextScaler.linear(value);

    notifyListeners();
  }

  // Resets the text scale to 1
  void reset() {
    textScale = TextScaler.linear(1);
    notifyListeners();
  }
}
