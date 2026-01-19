import 'package:get/get.dart';

class SavesController extends GetxController {
  final RxBool isSaved;

  SavesController({bool initialSaved = false}) : isSaved = initialSaved.obs;

  void toggleSave() {
    isSaved.value = !isSaved.value;
  }
}

// Global map of controllers
final Map<String, SavesController> _savesControllers = {};

SavesController getSavesController(
  String postId, {
  required bool initialSaved,
}) {
  if (_savesControllers.containsKey(postId)) {
    return _savesControllers[postId]!;
  } else {
    final controller = SavesController(initialSaved: initialSaved);
    _savesControllers[postId] = controller;
    return controller;
  }
}
