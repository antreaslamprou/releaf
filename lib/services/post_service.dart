import 'package:firebase_database/firebase_database.dart';
import 'package:releaf/services/stats_service.dart';
import 'package:releaf/services/user_service.dart';
import 'dart:io';
import 'package:releaf/utils/conversions.dart';

class PostService {
  // Get important user defined services for altering user and stats/total-posts
  // data
  final _userService = UserService();
  final _statsService = StatsService();

  // Get important firebase services for public data
  final _database = FirebaseDatabase.instance;

  // Get all posts from the current user
  Future<Map<String, dynamic>?> getPosts() async {
    String uid = _userService.getUserUID();
    if (uid.isEmpty) return null;

    final DatabaseReference postRef = _database.ref('posts/$uid');
    final DataSnapshot snapshot = await postRef.get();

    if (!snapshot.exists) return null;

    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  // Get a posts from post id
  Future<Map<dynamic, dynamic>> getPostById(String id) async {
    String uid = _userService.getUserUID();
    if (uid.isEmpty) return {};

    final userId = id.split('_')[0];
    final postDate = id.split('_')[1];

    final snpashot = await _database.ref('posts/$userId/$postDate').get();

    if (!snpashot.exists) return {};

    return snpashot.value as Map;
  }

  // Get all posts from the current user
  Future<Map<String, dynamic>?> getPostsByUID(String uid) async {
    if (uid.isEmpty) return null;

    final DatabaseReference postRef = _database.ref('posts/$uid');
    final DataSnapshot snapshot = await postRef.get();

    if (!snapshot.exists) return null;

    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  // Get daily post of current user for the date provided, if no date, the current
  // date is checked
  Future<Map<String, dynamic>> getDailyPost({String? date}) async {
    String uid = _userService.getUserUID();
    if (uid.isEmpty) return {};

    String postDate = date == null || date.isEmpty
        ? Conversions.getNowString()
        : date;

    final DatabaseReference postRef = _database.ref('posts/$uid/$postDate');
    final DataSnapshot snapshot = await postRef.get();
    if (!snapshot.exists) return {};

    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  // Return all friends posts to the current user based on the date provided
  Future<List<Map<dynamic, dynamic>>> getFriendsPosts(String date) async {
    final uid = _userService.getUserUID();
    if (uid.isEmpty) return [];

    final friends = await _userService.getFriends();
    if (friends.isEmpty) return [];

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

  // Get the current user's total post count
  Future<int> getTotalPosts() async {
    Map<String, dynamic>? posts = await getPosts();

    if (posts == null) return 0;
    return posts.length;
  }

  // Get the user's total post count
  Future<int> getTotalPostsByUID(String uid) async {
    Map<String, dynamic>? posts = await getPostsByUID(uid);

    if (posts == null) return 0;
    return posts.length;
  }

  // Create a post in the database for the current user, parameters of the image
  // and description need to be provided
  Future<String> createPost(File image, String descritpion) async {
    final uid = _userService.getUserUID();
    if (uid.isEmpty) return "Error: Invalid User";

    String date = Conversions.getNowString();

    try {
      final base64img = await Conversions.imageToBase(image);
      await _database.ref('posts/$uid/$date').set({
        'id': '${uid}_$date',
        'image': base64img,
        'description': descritpion,
      });

      // Update the all related data like users last post, hotstreaks, points
      // and total post count/stats
      await _userService.updateUserData('last_post', date);
      await _userService.updatePoints();
      await _userService.updateHotstreaks();
      await _statsService.addPostCount();

      return "Post created!";
    } catch (e) {
      return "Error: $e";
    }
  }

  // Add or remove a like depending on the action, post id need to be provided
  Future<bool> likePost(String postId) async {
    try {
      final currentUID = _userService.getUserUID();
      if (currentUID.isEmpty) return false;

      String friendUID = postId.split('_')[0];
      String date = postId.split('_')[1];

      final likeRef = _database.ref('posts/$friendUID/$date/likes/$currentUID');

      final snapshot = await likeRef.get();

      // If the post is already liked, remove the like, otherwise add it (update
      // the total likes/stats respectively)
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

  // Check the initial like status for the current user and a post, post id is
  // needed
  Future<bool> getUserLiked(String postId) async {
    try {
      final currentUID = _userService.getUserUID();
      if (currentUID.isEmpty) return false;

      String friendUID = postId.split('_')[0];
      String date = postId.split('_')[1];

      final likeRef = _database.ref('posts/$friendUID/$date/likes/$currentUID');

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

  // Add or remove a post from the saved postst depending on the action, post id
  // need to be provided
  Future<bool> savePost(String postId) async {
    try {
      final uid = _userService.getUserUID();
      if (uid.isEmpty) return false;

      final saveRef = _database.ref('users/$uid/saved_posts/$postId');

      final snapshot = await saveRef.get();

      // If the post is already saved, remove it from saved posts, otherwise add
      // it to the saved postst
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

  // Check the initial save status for the current user and a post, post id is
  // needed
  Future<bool> getUserSaved(String postId) async {
    try {
      final uid = _userService.getUserUID();
      if (uid.isEmpty) return false;

      final saveRef = _database.ref('users/$uid/saved_posts/$postId');

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

  Future<bool> postComment(String postId, String comment) async {
    try {
      final uid = _userService.getUserUID();
      if (uid.isEmpty) return false;

      String friendUID = postId.split('_')[0];
      String date = postId.split('_')[1];

      final commentId = '${DateTime.now().millisecondsSinceEpoch}_$uid';

      await _database.ref('posts/$friendUID/$date/comments/').update({
        commentId: comment,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<dynamic, dynamic>>> getComments(String postId) async {
    try {
      String postUserUID = postId.split('_')[0];
      String date = postId.split('_')[1];

      final commentsRef = _database.ref('posts/$postUserUID/$date/comments');

      final snapshot = await commentsRef.get();

      if (snapshot.exists) {
        if (snapshot.value is Map<dynamic, dynamic>) {
          final singleComment = snapshot.value as Map<dynamic, dynamic>;
          return singleComment.entries
              .map((entry) => {entry.key: entry.value})
              .toList();
        }

        return snapshot.value as List<Map<dynamic, dynamic>>;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
