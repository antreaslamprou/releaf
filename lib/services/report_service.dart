import 'package:firebase_database/firebase_database.dart';
import 'package:releaf/services/user_service.dart';

enum ReportType {
  violence('violence'),
  nudity('nudity'),
  drugs('drugs'),
  falseTask('false_task'),
  other('other');

  final String value;
  const ReportType(this.value);
}

class ReportService {
  // Get important user defined services for altering user data
  final _userService = UserService();

  // Get important firebase services for public data
  final _database = FirebaseDatabase.instance;

  // Creates a delete report into the database
  Future<bool> createReport(
    String currentUserUID,
    String postId,
    ReportType type,
  ) async {
    final isAlreadyReported = await _database
        .ref('reports/$currentUserUID/$postId')
        .get();
    if (isAlreadyReported.exists) return false;

    await _database.ref('reports/$currentUserUID/$postId').set({
      'type': type.value,
      'status': 'waiting',
      'post_id': postId,
    });

    return true;
  }

  // Deletes all reports regarding the current user
  Future<void> deleteReports() async {
    String uid = _userService.getUserUID();
    if (uid.isEmpty) return;

    await _database.ref('reports/$uid').remove();
  }
}
