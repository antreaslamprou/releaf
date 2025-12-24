import 'package:flutter/material.dart';
import 'package:releaf/components/like_button.dart';
import 'package:releaf/components/save_button.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/conversions.dart';

class Post extends StatefulWidget {
  const Post({
    super.key,
    required this.postData,
    this.isEditable = true,
    this.isSaveable = true,
  });

  // Widget parameters for the post, like and save button
  final Map<dynamic, dynamic> postData;
  final bool isEditable;
  final bool isSaveable;

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  // Get important user defined services for fetching/altering user and post data
  final _userService = UserService();

  // Data holders
  Map<dynamic, dynamic>? userData;
  int likeKey = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
  }

  // Fetches the user's data to show on the post
  void getData() async {
    final userDataTemp = await _userService.getUserDataById(
      widget.postData['id'].split('_')[0],
    );

    setState(() {
      userData = userDataTemp;
    });
  }

  // When the data is fethced, the post is shown, which contains the user's
  // avatar and name, the image, the post description, the likes and depending
  // on the page, the like and save buttons
  @override
  Widget build(BuildContext context) {
    return userData == null
        ? SizedBox()
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
                  const SizedBox(height: 5),
                  if (widget.postData['description'] != '')
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        Text(widget.postData['description'] ?? ''),
                      ],
                    ),
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
