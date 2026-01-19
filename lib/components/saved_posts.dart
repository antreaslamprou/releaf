import 'package:flutter/material.dart';
import 'package:releaf/components/post.dart';
import 'package:releaf/services/post_service.dart';
import 'package:releaf/services/user_service.dart';

class SavedPosts extends StatefulWidget {
  const SavedPosts({super.key});

  @override
  State<SavedPosts> createState() => _SavedPostsState();
}

class _SavedPostsState extends State<SavedPosts> {
  // Get important user defined services for fetching/altering user and post data
  final _userService = UserService();
  final _postService = PostService();

  // Data holders and state variables
  late List<Map<dynamic, dynamic>> savedPosts;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  // Loads the user saved posts
  void loadData() async {
    List<Map<dynamic, dynamic>> listTemp = [];
    final savedPostsKeys = await _userService.getSavedPosts();

    for (final postId in savedPostsKeys) {
      final post = await _postService.getPostById(postId);
      listTemp.add(post);
    }

    setState(() {
      savedPosts = listTemp;
      isLoading = false;
    });
  }

  // Shows the saved posts if available, otherwise a warning message
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : savedPosts.isEmpty
            ? Column(
                children: [
                  SizedBox(height: 30),
                  Text('There are no saved posts!'),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: savedPosts
                    .map((post) => Post(key: Key(post['id']), postData: post))
                    .toList(),
              ),
      ),
    );
  }
}
