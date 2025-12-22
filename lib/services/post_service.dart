import 'package:firebase_database/firebase_database.dart';
import 'package:releaf/services/user_service.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:releaf/utils/conversions.dart';

class PostService {
  final _userService = UserService();
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

  Future<Map<String, dynamic>> getDailyPost({String? date}) async {
    String? uid = _userService.getUserUID();

    String postDate = '';
    if (date == '' || date == null) {
      DateTime now = DateTime.now().toUtc();
      postDate = Conversions.dateToString(now);
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
    DateTime now = DateTime.now().toUtc();
    String date = DateFormat('yyyy-MM-dd').format(now);

    if (uid != '') {
      try {
        final base64img = await Conversions.imageToBase(image);
        await _database.ref('posts/$uid/$date').set({
          'id': '${uid}_$date',
          'image': base64img,
          'description': descritpion,
          'likes': {uid: true},
        });

        await _userService.updateUserData('last_post', date);
        await _userService.updatePoints();

        return "Post created!";
      } catch (e) {
        return "Error: $e";
      }
    }

    return "Error: Invalid User";
  }

  Future<String> updatePost(String postId) async {
    try {
      String currentUID = _userService.getUserUID();

      String userUID = postId.split('_')[0];
      String date = postId.split('_')[1];

      final likeRef = _database.ref('posts/$userUID/$date/likes/$currentUID');

      final snapshot = await likeRef.get();

      if (snapshot.exists) {
        await likeRef.remove();
      } else {
        await likeRef.set(true);
      }

      return 'Success';
    } catch (e) {
      return 'Error: $e';
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
}
