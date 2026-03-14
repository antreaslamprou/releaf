import 'package:firebase_database/firebase_database.dart';
import 'package:releaf/utils/conversions.dart';

class StatsService {
  // Get important firebase services for public data
  final _database = FirebaseDatabase.instance;

  // Add to the total posts for the current date
  Future<void> addPostCount() async {
    final date = Conversions.getNowString();

    int totalPosts = 0;
    try {
      final postRef = _database.ref('stats/$date/posts');
      final snapshot = await postRef.get();

      totalPosts = (snapshot.value as int) + 1;
    } catch (e) {
      totalPosts = 1;
    } finally {
      await _database.ref('stats/$date/posts').set(totalPosts);
    }
  }

  // Add or reduct to the total posts likes for the current date
  Future<void> editLikeCount(int value, {String? date}) async {
    date ??= Conversions.getNowString();

    int totalLikes = 0;
    try {
      final postRef = _database.ref('stats/$date/likes');
      final snapshot = await postRef.get();

      totalLikes = (snapshot.value as int) + value;
    } catch (e) {
      totalLikes = value;
    } finally {
      await _database.ref('stats/$date/likes').set(totalLikes);
    }
  }

  // Add to the total posts comments for the current date
  Future<void> updateCommentsCount({String? date}) async {
    date ??= Conversions.getNowString();

    int totalComments = 0;
    try {
      final postRef = _database.ref('stats/$date/comments');
      final snapshot = await postRef.get();

      totalComments = (snapshot.value as int) + 1;
    } catch (e) {
      totalComments = 1;
    } finally {
      await _database.ref('stats/$date/comments').set(totalComments);
    }
  }

  // Get total posts for the provided date
  Future<int> getTotalPosts(String date) async {
    int totalPosts = 0;
    try {
      final postRef = _database.ref('stats/$date/posts');
      final snapshot = await postRef.get();

      return snapshot.value as int;
    } catch (e) {
      return totalPosts;
    }
  }

  // Get total likes for the provided date
  Future<int> getTotalLikes(String date) async {
    int totalLikes = 0;
    try {
      final postRef = _database.ref('stats/$date/likes');
      final snapshot = await postRef.get();

      return snapshot.value as int;
    } catch (e) {
      return totalLikes;
    }
  }

  // Get total comments for the provided date
  Future<int> getTotalComments(String date) async {
    int totalComments = 0;
    try {
      final postRef = _database.ref('stats/$date/comments');
      final snapshot = await postRef.get();

      return snapshot.value as int;
    } catch (e) {
      return totalComments;
    }
  }
}
