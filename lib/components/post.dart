import 'package:flutter/material.dart';
import 'package:releaf/components/like_button.dart';
import 'package:releaf/components/save_button.dart';
import 'package:releaf/services/post_service.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/conversions.dart';

class Post extends StatefulWidget {
  const Post({
    super.key,
    required this.postData,
    this.isEditable = true,
    this.isSaveable = true,
  });

  final Map<dynamic, dynamic> postData;
  final bool isEditable;
  final bool isSaveable;

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  final userService = UserService();
  final postService = PostService();

  int likeKey = 0;
  bool isLiked = false;

  Map<dynamic, dynamic>? userData;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
  }

  void getData() async {
    final userDataTemp = await userService.getUserDataById(
      widget.postData['id'].split('_')[0],
    );

    setState(() {
      userData = userDataTemp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return userData == null
        ? const CircularProgressIndicator()
        : Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: MemoryImage(
                          Conversions.baseToImage(userData!["avatar"]),
                        ),
                        radius: 20,
                      ),
                      SizedBox(width: 15),
                      Text(
                        userData!["full_name"],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Image.memory(
                    Conversions.baseToImage(widget.postData['image']),
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 15),
                  Text(widget.postData['description'] ?? ''),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LikeButton(
                        key: ValueKey('${widget.postData['id']}-$likeKey'),
                        postId: widget.postData['id'],
                        isEditable: widget.isEditable,
                      ),
                      if (widget.isSaveable)
                        SaveButton(postId: widget.postData['id']),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}
