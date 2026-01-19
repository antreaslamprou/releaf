import 'package:flutter/material.dart';
import 'package:releaf/components/post.dart';
import 'package:releaf/services/post_service.dart';

class UserPosts extends StatefulWidget {
  const UserPosts({super.key, this.userId});

  final String? userId;

  @override
  State<UserPosts> createState() => _UserPostsState();
}

class _UserPostsState extends State<UserPosts> {
  // Get important user defined services for fetching/altering user and post data
  final _postService = PostService();

  // Data holders and state variables
  late Map<String, dynamic>? posts;
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
    final postsList = await _postService.getPosts(uid: widget.userId);

    setState(() {
      posts = postsList;
      isLoading = false;
    });
  }

  // Shows the user posts if available, otherwise a warning message
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : posts == null || posts!.isEmpty
            ? Text('You do not have any posts!')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: posts!.entries.map((entry) {
                  final value = entry.value;
                  return Post(
                    key: Key(value['id']),
                    postData: value,
                    isReportable: widget.userId != null,
                  );
                }).toList(),
              ),
      ),
    );
  }
}
