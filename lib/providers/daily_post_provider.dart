import 'package:flutter/material.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/conversions.dart';

class DailyPostProvider extends ChangeNotifier {
  // Get important user defined services for fetching/altering user data
  final _userService = UserService();

  // Default value of the daily post is set to false
  bool isDailyPosted = false;
  bool isLoading = true;

  // Initialization function to get if the user completed their daily task
  // it sets the text scale to 1
  Future<void> loadDailyPost() async {
    Map<String, dynamic> userData = await _userService.getUserData();

    final lastPost = DateTime.parse(userData['last_post']);
    final now = Conversions.getNow();

    final cleanNow = DateTime(now.year, now.month, now.day);
    final cleanLast = DateTime(lastPost.year, lastPost.month, lastPost.day);

    final diff = cleanNow.difference(cleanLast).inDays;

    isDailyPosted = diff < 1;
    isLoading = false;
    notifyListeners();
  }

  // Sets the value of the daily post to true, so the home page changes widget,
  // the leaderborad updates
  Future<void> completeDailyPost() async {
    isDailyPosted = true;
    notifyListeners();
  }

  // Resets the value of the daily post to false
  void reset() {
    isDailyPosted = false;
    isLoading = true;
    notifyListeners();
  }
}
