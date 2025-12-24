import 'package:flutter/material.dart';
import 'package:releaf/services/post_service.dart';
import 'package:releaf/utils/snackbar.dart';

class LikeButton extends StatefulWidget {
  const LikeButton({super.key, required this.postId, this.isEditable = true});

  // Widget variable with the post id and the show/hide of like button
  final String postId;
  final bool isEditable;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  // Get important user defined services for fetching/altering post data
  final PostService _postService = PostService();

  // Data holders
  bool liked = false;
  int likes = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLikeStatus();
    });
  }

  // Get wether the current user has already liked or not the current post and
  // the likes
  void getLikeStatus() async {
    final isLikedTemp = await _postService.getUserLiked(widget.postId);
    final postData = await _postService.getPostById(widget.postId);
    final likesTemp = postData['likes'] != null ? postData['likes'].length : 0;

    setState(() {
      liked = isLikedTemp;
      likes = likesTemp;
    });
  }

  // Toogles the like functionality to show the changes visually and update the
  // database
  void toggleLike() async {
    if (await _postService.likePost(widget.postId)) {
      setState(() {
        liked = !liked;
        likes += liked ? 1 : -1;
      });
      return;
    }
    if (!mounted) return;
    Snackbar.show(context, 'Error with liking this post!');
  }

  // Shows the likes and the like button depending on the widget variable
  // provided by the parent
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Likes:  $likes'),
        const SizedBox(width: 5),
        if (widget.isEditable)
          IconButton(
            icon: Icon(
              liked ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: toggleLike,
          ),
      ],
    );
  }
}
