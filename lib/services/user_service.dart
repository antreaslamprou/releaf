import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UserService {
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance;

  Future<bool> deleteUser() async {
    final User? user = _auth.currentUser;

    if (user == null) return false;

    final String uid = user.uid;

    await _database.ref('users/$uid').remove();
    FirebaseAuth.instance.currentUser!.delete();
    await FirebaseAuth.instance.signOut();

    return true;
  }

  Future<List<Map<dynamic, dynamic>>> getLeaderboard() async {
    final snapshot = await _database
        .ref('users')
        .orderByChild('points')
        .limitToLast(10)
        .get();

    if (!snapshot.exists) return [];

    final dataMap = snapshot.value as Map<dynamic, dynamic>;

    final topUsers =
        dataMap.values.map((e) => e as Map<dynamic, dynamic>).toList()
          ..sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));

    return topUsers;
  }

  Future<Map<String, dynamic>> getUserData() async {
    final User? user = _auth.currentUser;

    if (user == null) return {};

    final String uid = user.uid;
    final userRef = _database.ref('users/$uid');
    final DataSnapshot snapshot = await userRef.get();

    if (!snapshot.exists) return {};

    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  Future<Map<String, dynamic>?> getUserDataById(String userId) async {
    final userRef = _database.ref('users/$userId');
    final DataSnapshot snapshot = await userRef.get();

    if (!snapshot.exists) return null;

    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  Future<bool> checkUsernameAvailability(String username) async {
    final snapshot = await _database
        .ref('users')
        .orderByChild('username')
        .equalTo(username.toLowerCase())
        .get();

    if (snapshot.exists) return false;

    return true;
  }

  Future<String> getUserUIDFromUsername(String username) async {
    final snapshot = await _database
        .ref('users')
        .orderByChild('username')
        .equalTo(username.toLowerCase())
        .get();

    if (!snapshot.exists) return '';

    final user = snapshot.children.first;
    return user.key ?? '';
  }

  Future<String> getUsernameFromUID(String uid) async {
    final snapshot = await _database.ref('users/$uid').get();

    if (!snapshot.exists) return '';

    final data = snapshot.value as Map<dynamic, dynamic>;
    return data['username'] as String;
  }

  String getUserUID() {
    final User? user = _auth.currentUser;

    if (user == null) return '';

    return user.uid;
  }

  String getUserEmail() {
    final User? user = _auth.currentUser;

    if (user == null) return '';

    return user.email!;
  }

  Future<bool> updateUserData(String key, dynamic value) async {
    final User? user = _auth.currentUser;

    if (user == null) return false;

    try {
      final String uid = user.uid;
      await _database.ref('users/$uid').update({key: value});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePoints() async {
    final User? user = _auth.currentUser;

    if (user == null) return false;

    try {
      final uid = user.uid;

      final pointsSnap = await _database.ref('users/$uid/points').get();
      final hotstreakSnap = await _database.ref('users/$uid/hotstreaks').get();

      final int points = (pointsSnap.value as int?) ?? 0;
      final int hotstreak = (hotstreakSnap.value as int?) ?? 0;

      final newPoints = points + hotstreak + 1;

      await _database.ref('users/$uid/points').set(newPoints);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getFriends() async {
    final User? user = _auth.currentUser;

    if (user == null) return [];

    try {
      final String uid = user.uid;
      final snapshot = await _database.ref('users/$uid/friends').get();
      final friendsMap = snapshot.value as Map<dynamic, dynamic>?;

      if (friendsMap == null) return [];

      return friendsMap.keys.toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> addFriend(String uid) async {
    final User? user = _auth.currentUser;

    if (user == null) return false;

    try {
      final String currentUID = user.uid;
      await _database.ref('users/$currentUID/friends/$uid').set(true);
      await _database.ref('users/$uid/friends/$currentUID').set(true);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFriend(String uid) async {
    final User? user = _auth.currentUser;

    if (user == null) return false;

    try {
      final String currentUID = user.uid;
      await _database.ref('users/$currentUID/friends/$uid').remove();
      await _database.ref('users/$uid/friends/$currentUID').remove();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getSavedPosts() async {
    final User? user = _auth.currentUser;

    if (user == null) return [];

    final String currentUID = user.uid;
    final snapshot = await _database
        .ref('users/$currentUID/saved_posts/')
        .get();

    if (snapshot.exists) {
      final value = snapshot.value as Map;
      return value.keys.toList();
    } else {
      return [];
    }
  }
}
