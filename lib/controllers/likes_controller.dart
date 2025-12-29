import 'package:flutter/material.dart';

class LikesController {
  // Data holders
  final ValueNotifier<int> count;
  final ValueNotifier<bool> isLiked;

  // Likes controller constructor
  LikesController({required int initialCount, required bool initialLiked})
    : count = ValueNotifier(initialCount),
      isLiked = ValueNotifier(initialLiked);

  // Toggles the UI like functionality
  void toggleLike() {
    if (isLiked.value) {
      count.value--;
    } else {
      count.value++;
    }
    isLiked.value = !isLiked.value;
  }

  // Dispose the controller variables
  void dispose() {
    count.dispose();
    isLiked.dispose();
  }
}
