import 'package:flutter/material.dart';
import 'package:releaf/components/post.dart';

class SinglePost extends StatelessWidget {
  const SinglePost({super.key, required this.postData});

  final Map<dynamic, dynamic> postData;

  // Shows the user posts if available, otherwise a warning message
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(15, 0, 25, 15),
      child: Post(postData: postData),
    );
  }
}
