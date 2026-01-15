import 'package:firebase_database/firebase_database.dart';

enum ReportType {
  violence('violence'),
  nudity('nudity'),
  falseTask('false_task');

  final String value;
  const ReportType(this.value);
}

class ReportService {
  // Get important firebase services for public data
  final _database = FirebaseDatabase.instance;

  Future<bool> createReport(
    String currentUserUID,
    String postId,
    ReportType type,
  ) async {
    final isAlreadyReported = await _database
        .ref('reports/${currentUserUID}_$postId')
        .get();
    if (isAlreadyReported.exists) return false;

    await _database.ref('reports/${currentUserUID}_$postId').set({
      'type': type.value,
      'status': 'waiting',
      'post_id': postId,
    });

    return true;
  }
}
