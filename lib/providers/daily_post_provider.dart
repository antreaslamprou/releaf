import 'package:flutter/material.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/conversions.dart';

class DailyPostProvider extends ChangeNotifier {
  final userService = UserService();
  late bool isDailyPosted;
  bool isLoading = true;

  Future<void> loadDailyPost() async {
    print('loadDailyPost called');
    Map<String, dynamic> userData = await userService.getUserData();

    if (userData['last_post'] == null || userData['last_post'] == '') {
      isDailyPosted = false;
      isLoading = false;
      print('isDailyPosted = false due to invalidity');
      notifyListeners();
      return;
    }

    final lastPost = DateTime.parse(userData['last_post']);
    final now = Conversions.getNow();

    final cleanNow = DateTime(now.year, now.month, now.day);
    final cleanLast = DateTime(lastPost.year, lastPost.month, lastPost.day);

    final diff = cleanNow.difference(cleanLast).inDays;

    isDailyPosted = diff < 1;
    isLoading = false;
    print('isDailyPosted = $isDailyPosted');

    notifyListeners();
  }

  Future<void> completeDailyPost() async {
    isDailyPosted = true;

    notifyListeners();
  }
}
