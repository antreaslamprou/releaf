import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:releaf/services/friend_request_service.dart';
import 'package:releaf/utils/conversions.dart';

class UserService {
  // Get important firebase services for public ans sensitive data
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance;

  // Returns the current user's id, if available, from auth
  String getUserUID() {
    final User? user = _auth.currentUser;

    if (user == null) return '';

    return user.uid;
  }

  // Returns the current user's email, if available, from auth
  String getUserEmail() {
    final User? user = _auth.currentUser;

    if (user == null) return '';

    return user.email!;
  }

  // Checks if a username is already taken, and returns wether the username is
  // available or not
  Future<bool> checkUsernameAvailability(String username) async {
    final snapshot = await _database
        .ref('users')
        .orderByChild('username')
        .equalTo(username.toLowerCase())
        .get();

    if (snapshot.exists) return false;

    return true;
  }

  // Get all data stored in firebase realtime database regarding the user
  Future<Map<String, dynamic>> getUserData({String? uid}) async {
    uid ??= getUserUID();

    final userRef = _database.ref('users/$uid');
    final DataSnapshot snapshot = await userRef.get();

    if (!snapshot.exists) return {};

    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  // Get the user UID from the user username
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

  // Get the user username from the user UID
  Future<String> getUsernameFromUID(String uid) async {
    final snapshot = await _database.ref('users/$uid').get();

    if (!snapshot.exists) return '';

    final data = snapshot.value as Map<dynamic, dynamic>;
    return data['username'] as String;
  }

  // Deletes the user from the system
  Future<bool> deleteUser() async {
    final String uid = getUserUID();
    if (uid.isEmpty) return false;

    // Remove any friends connections
    final friendsList = await getFriends();
    if (friendsList.isNotEmpty) {
      for (final friendId in friendsList) {
        removeFriend(friendId);
      }
    }

    // Remove any incoming or outgoing friend requests
    final friendRequestService = FriendRequestService();
    await friendRequestService.deleteRequest(receiverId: uid);
    await friendRequestService.deleteRequest(senderId: uid);

    // Remove the user from the database and auth system
    await _database.ref('users/$uid').remove();
    await FirebaseAuth.instance.currentUser!.delete();
    await FirebaseAuth.instance.signOut();

    return true;
  }

  // Gets the first 10 users ordered by points
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

  // Updates any data for the current user, by providing the key of the data and
  // the value of the data
  Future<bool> updateUserData(String key, dynamic value) async {
    final String uid = getUserUID();
    if (uid.isEmpty) return false;

    try {
      await _database.ref('users/$uid').update({key: value});
      return true;
    } catch (e) {
      return false;
    }
  }

  // Updates the email of the current user
  Future<bool> updateUserEmail(String value) async {
    final User? user = _auth.currentUser;
    if (user == null) return false;

    try {
      await user.verifyBeforeUpdateEmail(value);
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  // Updates the password of the current user
  Future<bool> updateUserPassword(String value) async {
    final User? user = _auth.currentUser;
    if (user == null) return false;

    try {
      await user.updatePassword(value);
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  // Updates the current user points based on the hotstreaks
  Future<bool> updatePoints() async {
    final String uid = getUserUID();
    if (uid.isEmpty) return false;

    try {
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

  // Returns the user's friends keys
  Future<List<dynamic>> getFriends({String? uid}) async {
    uid ??= getUserUID();

    try {
      final snapshot = await _database.ref('users/$uid/friends').get();
      final friendsMap = snapshot.value as Map<dynamic, dynamic>?;

      if (friendsMap == null) return [];

      return friendsMap.keys.toList();
    } catch (e) {
      return [];
    }
  }

  // Create the connection on both users when they become friends
  Future<bool> addFriend(String friendUID) async {
    final String uid = getUserUID();
    if (uid.isEmpty) return false;

    try {
      await _database.ref('users/$uid/friends/$friendUID').set(true);
      await _database.ref('users/$friendUID/friends/$uid').set(true);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Remove the connection on both users when they unfriend
  Future<bool> removeFriend(String friendUID) async {
    final String uid = getUserUID();
    if (uid.isEmpty) return false;

    try {
      await _database.ref('users/$uid/friends/$friendUID').remove();
      await _database.ref('users/$friendUID/friends/$uid').remove();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get all saved post ids
  Future<List<dynamic>> getSavedPosts() async {
    final String uid = getUserUID();
    if (uid.isEmpty) return [];

    final snapshot = await _database.ref('users/$uid/saved_posts/').get();

    if (snapshot.exists) {
      final value = snapshot.value as Map;
      return value.keys.toList();
    } else {
      return [];
    }
  }

  // Check wether the current user should lost its streaks if the last time they
  // posted were two days or more (since if its one day, they can still post and
  // keep up with their streak)
  Future<void> checkHotstreaks() async {
    final String uid = getUserUID();
    if (uid.isEmpty) return;

    final userData = await getUserData();
    final lastPostString = userData['last_post'] != ''
        ? userData['last_post']
        : '2000-01-01';

    final lastPost = DateTime.parse(lastPostString);
    final now = Conversions.getNow();

    final cleanNow = DateTime(now.year, now.month, now.day);
    final cleanLast = DateTime(lastPost.year, lastPost.month, lastPost.day);

    final diff = cleanNow.difference(cleanLast).inDays;

    bool isStreakLost = diff > 1;

    if (isStreakLost) await updateUserData('hotstreaks', 0);
  }

  // Update the current user's hotstreaks approprietly
  Future<void> updateHotstreaks() async {
    final String uid = getUserUID();
    if (uid.isEmpty) return;

    final userData = await getUserData();

    final hotstreaks = userData['hotstreaks'];
    final newHotstreaks = hotstreaks + 1;

    await updateUserData('hotstreaks', newHotstreaks);
  }

  Future<num> getTotalBadges({String? uid}) async {
    uid ??= getUserUID();

    final userData = await getUserData(uid: uid);
    final badges = userData['badges'];

    num total = 0;
    badges.forEach((key, value) => total += value);

    return total;
  }

  // Update the current user's budge
  Future<void> updateBadgeProgress(String badgeId) async {
    // Check user
    final String uid = getUserUID();
    if (uid.isEmpty) return;

    // Get the badge current progress
    final userData = await getUserData();
    final value = userData['badges'][badgeId];

    // Update badge progress
    await _database.ref('users/$uid/badges/$badgeId').set(value);
  }
}
