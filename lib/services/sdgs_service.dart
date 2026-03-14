import 'package:firebase_database/firebase_database.dart';
import 'package:releaf/services/user_service.dart';

class SdgsService {
  // Get important user defined services for altering user data
  final _userService = UserService();

  // Get important firebase services for public data
  final _database = FirebaseDatabase.instance;

  Future<Map<dynamic, dynamic>> getSDGS() async {
    final uid = _userService.getUserUID();
    if (uid.isEmpty) return {};

    // Get the SDGs
    final sdgs = await _database.ref('sdgs').get();
    if (!sdgs.exists) return {};

    // Sort by SDG acsending
    final Map<dynamic, dynamic> sdgsMap = Map<dynamic, dynamic>.from(
      sdgs.value as Map,
    );

    final sortedMap = Map.fromEntries(
      sdgsMap.entries.toList()..sort((a, b) {
        final aNum = int.parse(a.key.toString().replaceAll('sdg', ''));
        final bNum = int.parse(b.key.toString().replaceAll('sdg', ''));
        return aNum.compareTo(bNum);
      }),
    );

    return sortedMap;
  }
}
