import 'package:flutter/material.dart';
import 'package:releaf/services/post_service.dart';
import 'package:releaf/utils/snackbar.dart';

class LikeButton extends StatefulWidget {
  const LikeButton({super.key, required this.postId, this.isEditable = true});

  final String postId;
  final bool isEditable;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  PostService postService = PostService();
  bool liked = false;
  int likes = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLikeStatus();
    });
  }

  void getLikeStatus() async {
    final isLikedTemp = await postService.getUserLiked(widget.postId);
    final postData = await postService.getPostById(widget.postId);
    final likesTemp = postData['likes'] != null ? postData['likes'].length : 0;

    setState(() {
      liked = isLikedTemp;
      likes = likesTemp;
    });
  }

  void toggleLike() async {
    if (await postService.likePost(widget.postId)) {
      setState(() {
        liked = !liked;
        likes += liked ? 1 : -1;
      });
      return;
    }
    if (!mounted) return;
    Snackbar.show(context, 'Error with liking this post!');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Likes: '),
        Text(' $likes'),
        widget.isEditable
            ? IconButton(
                icon: Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: toggleLike,
              )
            : SizedBox(height: 50),
      ],
    );
  }
}
