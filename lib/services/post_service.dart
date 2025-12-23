import 'package:firebase_database/firebase_database.dart';
import 'package:releaf/services/stats_service.dart';
import 'package:releaf/services/user_service.dart';
import 'dart:io';
import 'package:releaf/utils/conversions.dart';

class PostService {
  final _userService = UserService();
  final _statsService = StatsService();
  final _database = FirebaseDatabase.instance;

  Future<Map<String, dynamic>?> getPosts() async {
    String? uid = _userService.getUserUID();

    if (uid != '') {
      final DatabaseReference postRef = _database.ref('posts/$uid');
      final DataSnapshot snapshot = await postRef.get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
    }

    return null;
  }

  Future<Map<dynamic, dynamic>> getPostById(String id) async {
    String? uid = _userService.getUserUID();

    if (uid != '') {
      final userId = id.split('_')[0];
      final postDate = id.split('_')[1];

      final snpashot = await _database.ref('posts/$userId/$postDate').get();

      if (!snpashot.exists) return {};

      return snpashot.value as Map;
    }

    return {};
  }

  Future<Map<String, dynamic>> getDailyPost({String? date}) async {
    String? uid = _userService.getUserUID();

    String postDate = '';
    if (date == '' || date == null) {
      postDate = Conversions.getNowString();
    } else {
      postDate = date;
    }

    if (uid != '') {
      final DatabaseReference postRef = _database.ref('posts/$uid/$postDate');
      final DataSnapshot snapshot = await postRef.get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
    }

    return {};
  }

  Future<List<Map<dynamic, dynamic>>> getFriendsPosts(String date) async {
    final uid = _userService.getUserUID();
    final friends = await _userService.getFriends();

    if (uid == '' || friends.isEmpty) return [];

    List<Map<dynamic, dynamic>> list = [];

    for (final friendId in friends) {
      final ref = _database.ref('posts/$friendId/$date');
      final snapshot = await ref.get();

      if (snapshot.exists && snapshot.value != null) {
        list.add(snapshot.value as Map<dynamic, dynamic>);
      }
    }

    return list;
  }

  Future<int> getTotalPosts() async {
    Map<String, dynamic>? posts = await getPosts();

    if (posts == null) return 0;
    return posts.length;
  }

  Future<String> createPost(File image, String descritpion) async {
    String? uid = _userService.getUserUID();
    String date = Conversions.getNowString();

    if (uid != '') {
      try {
        final base64img = await Conversions.imageToBase(image);
        await _database.ref('posts/$uid/$date').set({
          'id': '${uid}_$date',
          'image': base64img,
          'description': descritpion,
        });

        await _userService.updateUserData('last_post', date);
        await _userService.updatePoints();
        await _userService.updateHotstreaks();
        await _statsService.addPostCount();

        return "Post created!";
      } catch (e) {
        return "Error: $e";
      }
    }

    return "Error: Invalid User";
  }

  Future<bool> likePost(String postId) async {
    try {
      String currentUID = _userService.getUserUID();

      String userUID = postId.split('_')[0];
      String date = postId.split('_')[1];

      final likeRef = _database.ref('posts/$userUID/$date/likes/$currentUID');

      final snapshot = await likeRef.get();

      if (snapshot.exists) {
        await likeRef.remove();
        await _statsService.editLikeCount(-1);
      } else {
        await likeRef.set(true);
        await _statsService.editLikeCount(1);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> getUserLiked(String postId) async {
    try {
      String currentUID = _userService.getUserUID();

      String userUID = postId.split('_')[0];
      String date = postId.split('_')[1];

      final likeRef = _database.ref('posts/$userUID/$date/likes/$currentUID');

      final snapshot = await likeRef.get();

      if (snapshot.exists) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> savePost(String postId) async {
    try {
      String userUID = _userService.getUserUID();

      final saveRef = _database.ref('users/$userUID/saved_posts/$postId');

      final snapshot = await saveRef.get();

      if (snapshot.exists) {
        await saveRef.remove();
      } else {
        await saveRef.set(true);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> getUserSaved(String postId) async {
    try {
      String userUID = _userService.getUserUID();

      final saveRef = _database.ref('users/$userUID/saved_posts/$postId');

      final snapshot = await saveRef.get();

      if (snapshot.exists) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
