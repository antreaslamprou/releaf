import 'package:flutter/material.dart';
import 'package:releaf/services/user_service.dart';

class TextScaleProvider extends ChangeNotifier {
  final userService = UserService();
  TextScaler textScale = TextScaler.linear(1);

  double get scaleFactor => textScale.scale(1.0);

  Future<void> loadTextScale() async {
    final userData = await userService.getUserData();

    if (userData.isEmpty) return;

    textScale = userData['text_scale'] != null
        ? TextScaler.linear(userData['text_scale'].toDouble())
        : TextScaler.linear(1);

    notifyListeners();
  }

  Future<void> setTextScale() async {
    final value = scaleFactor == 1 ? 1.2 : 1.0;
    await userService.updateUserData('text_scale', value);
    textScale = TextScaler.linear(value);

    notifyListeners();
  }

  void reset() {
    textScale = TextScaler.linear(1);
    notifyListeners();
  }
}
