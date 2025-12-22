import 'package:flutter/material.dart';
import 'package:releaf/services/post_service.dart';

class LikeButton extends StatefulWidget {
  const LikeButton({
    super.key,
    required this.postId,
    required this.initialLikes,
    required this.initiallyLiked,
    this.isEditable = true,
  });

  final String postId;
  final int initialLikes;
  final bool initiallyLiked;
  final bool isEditable;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  PostService postService = PostService();
  late bool liked;
  late int likes;

  @override
  void initState() {
    super.initState();
    
    liked = widget.initiallyLiked;
    likes = widget.initialLikes;
  }

  void toggleLike() async {
    setState(() {
      liked = !liked;
      likes += liked ? 1 : -1;
    });
    await postService.updatePost(widget.postId);
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
