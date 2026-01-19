import 'package:get/get.dart';

class LikesController extends GetxController {
  RxInt count;
  RxBool isLiked;

  LikesController({int initialCount = 0, bool initialLiked = false})
    : count = initialCount.obs,
      isLiked = initialLiked.obs;

  void toggleLike() {
    isLiked.value = !isLiked.value;
    count.value += isLiked.value ? 1 : -1;
  }
}

// Global map of controllers
final Map<String, LikesController> _likesControllers = {};

LikesController getLikesController(
  String postId, {
  int initialCount = 0,
  bool initialLiked = false,
}) {
  if (_likesControllers.containsKey(postId)) {
    return _likesControllers[postId]!;
  } else {
    final controller = LikesController(
      initialCount: initialCount,
      initialLiked: initialLiked,
    );
    _likesControllers[postId] = controller;
    return controller;
  }
}
