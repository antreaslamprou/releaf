import 'package:flutter/material.dart';

class SavesController {
  // Data holder
  final ValueNotifier<bool> isSaved;

  // Likes controller constructor
  SavesController(bool initialSaved) : isSaved = ValueNotifier(initialSaved);

  // Toggles the UI like functionality
  void toggleSave() {
    isSaved.value = !isSaved.value;
  }

  // Dispose the controller variables
  void dispose() {
    isSaved.dispose();
  }
}
