import 'package:firebase_database/firebase_database.dart';
import 'package:releaf/services/user_service.dart';

class SuggestedTaskService {
  // Get important user defined services for altering user data
  final _userService = UserService();

  // Get important firebase services for public data
  final _database = FirebaseDatabase.instance;

  Future<List<Map<dynamic, dynamic>>> getSuggestedTasks() async {
    final uid = _userService.getUserUID();
    if (uid.isEmpty) return [];

    final tasks = await _database.ref('suggested_tasks/$uid').get();
    if (!tasks.exists) return [];

    List<Map<dynamic, dynamic>> tasksList = [];

    if (tasks.value is Map) {
      tasksList.add(tasks.value as Map<dynamic, dynamic>);
    } else {
      tasksList = tasks.value as List<Map<dynamic, dynamic>>;
    }

    return tasksList;
  }

  Future<void> createSuggestedTasks(
    String taskTitle,
    String taskSDG,
    String taskDescription,
  ) async {
    final uid = _userService.getUserUID();
    if (uid.isEmpty) return;

    await _database.ref('suggested_tasks/$uid').push().set({
      'title': taskTitle,
      'sdg': taskSDG,
      'description': taskDescription,
      'status': 'waiting',
    });
  }
}
