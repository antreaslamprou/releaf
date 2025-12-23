import 'package:flutter/material.dart';
import 'package:releaf/services/user_service.dart';

class TextScaleProvider extends ChangeNotifier {
  final userService = UserService();
  TextScaler textScale = TextScaler.linear(1);

  Future<void> loadTextScale() async {
    final userData = await userService.getUserData();

    if (userData.isEmpty) return;

    textScale = userData['text_scale'] ?? TextScaler.linear(1);

    notifyListeners();
  }

  Future<void> editTextScale(double value) async {
    await userService.updateUserData('text_scale', value);
    textScale = TextScaler.linear(value);

    notifyListeners();
  }
}
