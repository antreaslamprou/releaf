import 'dart:math';
import 'package:firebase_database/firebase_database.dart';

class TaskService {
  final _database = FirebaseDatabase.instance;

  Future<Map<dynamic, dynamic>> getDailyTask({String? date}) async {
    final DatabaseReference taskRef = _database.ref('tasks');
    final DataSnapshot snapshot = await taskRef.get();

    if (!snapshot.exists) return {};

    final taskKeys = snapshot.children.map((e) => e.key!).toList();

    final today = date == '' || date == null
        ? DateTime.now().toUtc()
        : DateTime.parse(date);
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final random = Random(seed);

    final dailyTaskKey = taskKeys[random.nextInt(taskKeys.length)];
    return snapshot.child(dailyTaskKey).value as Map;
  }
}
