import 'package:flutter/material.dart';
import 'package:releaf/services/user_service.dart';

class DailyPostProvider extends ChangeNotifier {
  final userService = UserService();
  late bool isDailyPosted;

  Future<void> loadDailyPost() async {
    Map<String, dynamic> userData = await userService.getUserData();

    if (userData['last_post'] == null || userData['last_post'] == '') {
      isDailyPosted = false;

      return notifyListeners();
    }

    final lastPost = DateTime.parse(userData['last_post']);
    final now = DateTime.now().toUtc();

    final cleanNow = DateTime(now.year, now.month, now.day);
    final cleanLast = DateTime(lastPost.year, lastPost.month, lastPost.day);

    final diff = cleanNow.difference(cleanLast).inDays;

    isDailyPosted = diff < 1;

    notifyListeners();
  }

  Future<void> completeDailyPost() async {
    isDailyPosted = true;

    notifyListeners();
  }
}
