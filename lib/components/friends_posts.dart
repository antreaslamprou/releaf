import 'package:flutter/material.dart';
import 'package:releaf/components/post.dart';
import 'package:releaf/services/post_service.dart';
import 'package:releaf/services/user_service.dart';

class FriendsPosts extends StatefulWidget {
  const FriendsPosts({super.key, required this.date, this.isEditable = true});

  final String date;
  final bool isEditable;

  @override
  State<FriendsPosts> createState() => _FriendsPostsState();
}

class _FriendsPostsState extends State<FriendsPosts> {
  UserService userService = UserService();
  PostService postService = PostService();

  List<Map<dynamic, dynamic>> postData = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  void init() async {
    final tempList = await postService.getFriendsPosts(widget.date);

    setState(() {
      postData = tempList;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : postData.isEmpty
            ? Column(
                children: [
                  SizedBox(height: 15),
                  Text('No available friends posts!'),
                  SizedBox(height: 30),
                ],
              )
            : Column(
                children: postData
                    .map(
                      (post) => Post(
                        key: ValueKey(post['id']),
                        postData: post,
                        isEditable: widget.isEditable,
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }
}
