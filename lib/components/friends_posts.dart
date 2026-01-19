import 'package:flutter/material.dart';
import 'package:releaf/components/post.dart';
import 'package:releaf/services/post_service.dart';

class FriendsPosts extends StatefulWidget {
  const FriendsPosts({super.key, required this.date});

  // Widget parameters used to fetch correctly the post data from a data and to
  // show/hide post actions
  final String date;

  @override
  State<FriendsPosts> createState() => _FriendsPostsState();
}

class _FriendsPostsState extends State<FriendsPosts> {
  // Get important user defined services for fetching/altering post data
  final _postService = PostService();

  // Data holders and state variables
  List<Map<dynamic, dynamic>> postData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  // Fetches all friends posts
  void init() async {
    final tempList = await _postService.getFriendsPosts(widget.date);

    if (!mounted) return;
    setState(() {
      postData = tempList;
      isLoading = false;
    });
  }

  // After the data are fetched, the loader is removed and the friends posts for
  // a defined date are shown, otherwise a message
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
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }
}
