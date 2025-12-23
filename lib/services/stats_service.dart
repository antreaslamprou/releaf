import 'package:firebase_database/firebase_database.dart';
import 'package:releaf/utils/conversions.dart';

class StatsService {
  final _database = FirebaseDatabase.instance;

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

  Future<void> editLikeCount(int value) async {
    final date = Conversions.getNowString();

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
}
