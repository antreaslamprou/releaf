import 'package:flutter/material.dart';

class CommentsController {
  // Data holders
  final ValueNotifier<bool> isCommentsOpen;

  // Comments controller constructor, with comments section closed by default
  CommentsController({bool initialCommentStatus = false})
    : isCommentsOpen = ValueNotifier(initialCommentStatus);

  // Toggles the UI comments section functionality
  void toggleCommentSection() {
    isCommentsOpen.value = !isCommentsOpen.value;
  }

  // Dispose the controller variables
  void dispose() {
    isCommentsOpen.dispose();
  }
}
