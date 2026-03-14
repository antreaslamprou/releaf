import 'package:flutter/material.dart';

class UserDetailsProvider extends ChangeNotifier {
  // Notifies listeners to be triggered
  void trigger() {
    notifyListeners();
  }
}
