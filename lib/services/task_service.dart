import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:releaf/utils/conversions.dart';

class TaskService {
  final _database = FirebaseDatabase.instance;

  Future<Map<dynamic, dynamic>> getDailyTask({String? date}) async {
    final DatabaseReference taskRef = _database.ref('tasks');
    final DataSnapshot snapshot = await taskRef.get();

    if (!snapshot.exists) return {};

    final taskKeys = snapshot.children.map((e) => e.key!).toList();

    final today = date == '' || date == null
        ? Conversions.getNow()
        : DateTime.parse(date);
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final random = Random(seed);

    final dailyTaskKey = taskKeys[random.nextInt(taskKeys.length)];
    return snapshot.child(dailyTaskKey).value as Map;
  }

  Future<Map<dynamic, dynamic>> getTaskByTitle(String title) async {
    final snapshot = await _database
        .ref('tasks')
        .orderByChild('title')
        .equalTo(title)
        .get();

    if (!snapshot.exists) return {};

    final task = snapshot.children.first;
    return task.value as Map;
  }
}
