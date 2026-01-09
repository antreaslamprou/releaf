import 'package:flutter/material.dart';
import 'package:releaf/components/comments_section.dart';
import 'package:releaf/controllers/comments_controller.dart';
import 'package:releaf/controllers/likes_controller.dart';
import 'package:releaf/controllers/saves_controller.dart';
import 'package:releaf/services/post_service.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/conversions.dart';
import 'package:releaf/utils/snackbar.dart';

class Post extends StatefulWidget {
  const Post({super.key, required this.postData, this.isEditable = true});

  // Widget parameters for the post, like and save button
  final Map<dynamic, dynamic> postData;
  final bool isEditable;

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  // Get important user defined services for fetching/altering user and post data
  final _userService = UserService();
  final _postService = PostService();

  // Data holders
  late final LikesController likesController;
  late final CommentsController commentsController = CommentsController();
  late final SavesController savesController;
  Map<dynamic, dynamic>? userData;
  int likeKey = 0;
  int likes = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  // Fetches the user's data to show on the post, and initializes the action
  // controllers (likes, comments, saves)
  Future<void> init() async {
    final postId = widget.postData['id'];
    final userId = postId.split('_')[0];

    final userDataTemp = await _userService.getUserDataById(userId);

    final isLikedTemp = await _postService.getUserLiked(postId);
    final postData = await _postService.getPostById(postId);
    final likesTemp = postData['likes'] != null ? postData['likes'].length : 0;

    final isSavedTemp = await _postService.getUserSaved(postId);

    if (!mounted) return;
    setState(() {
      userData = userDataTemp;

      likesController = LikesController(
        initialCount: likesTemp,
        initialLiked: isLikedTemp,
      );

      savesController = SavesController(isSavedTemp);
    });
  }

  // Updates the UI and also the database on like/unlike
  void toggleLikes() async {
    likesController.toggleLike();
    try {
      await _postService.likePost(widget.postData['id']);
    } catch (e) {
      likesController.toggleLike();
      if (!mounted) return;
      Snackbar.show(context, 'Error with liking the post');
    }
  }

  // Updates the UI and also the database on save/unsave
  void toggleSaves() async {
    savesController.toggleSave();
    try {
      await _postService.savePost(widget.postData['id']);
    } catch (e) {
      savesController.toggleSave();
      if (!mounted) return;
      Snackbar.show(context, 'Error with saving the post');
    }
  }

  // Updates the UI and also the fetches comments
  void toggleCommentsSection() async {
    commentsController.toggleCommentSection();
    try {
      await _postService.getComments(widget.postData['id']);
    } catch (e) {
      commentsController.toggleCommentSection();
      if (!mounted) return;
      Snackbar.show(context, 'Error with saving the post');
    }
  }

  // When the data is fethced, the post is shown, which contains the user's
  // avatar and name, the image, the post description, the likes and depending
  // on the page, the like and save buttons
  @override
  Widget build(BuildContext context) {
    return userData == null
        ? SizedBox()
        : Column(
            children: [
              Card(
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
                            userData!["username"],
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.red, size: 18),
                          const SizedBox(width: 5),
                          ValueListenableBuilder<int>(
                            valueListenable: likesController.count,
                            builder: (_, count, _) {
                              return Text(count.toString());
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Like button
                          if (widget.isEditable)
                            ValueListenableBuilder<bool>(
                              valueListenable: likesController.isLiked,
                              builder: (_, isLiked, _) {
                                return TextButton(
                                  onPressed: toggleLikes,
                                  child: Row(
                                    children: [
                                      Icon(
                                        isLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                      ),
                                      SizedBox(width: 5),
                                      Text(isLiked ? 'Liked' : 'Like'),
                                    ],
                                  ),
                                );
                              },
                            ),

                          // Comment button
                          ValueListenableBuilder<bool>(
                            valueListenable: commentsController.isCommentsOpen,
                            builder: (_, isCommentsOpen, _) {
                              return TextButton(
                                onPressed: toggleCommentsSection,
                                child: Row(
                                  children: [
                                    Icon(
                                      isCommentsOpen
                                          ? Icons.comment
                                          : Icons.comment_outlined,
                                    ),
                                    SizedBox(width: 5),
                                    Text('Comments'),
                                  ],
                                ),
                              );
                            },
                          ),

                          // Save button
                          ValueListenableBuilder<bool>(
                            valueListenable: savesController.isSaved,
                            builder: (_, isSaved, _) {
                              return TextButton(
                                onPressed: toggleSaves,
                                child: Row(
                                  children: [
                                    Icon(
                                      isSaved
                                          ? Icons.bookmark_rounded
                                          : Icons.bookmark_border_rounded,
                                    ),
                                    SizedBox(width: 5),
                                    Text(isSaved ? 'Saved' : 'Save'),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: commentsController.isCommentsOpen,
                builder: (_, isCommentsOpen, _) {
                  return isCommentsOpen
                      ? Transform.translate(
                          offset: const Offset(0, -10),
                          child: FractionallySizedBox(
                            widthFactor: 1,
                            child: CommentsSection(
                              postId: widget.postData['id'],
                            ),
                          ),
                        )
                      : const SizedBox();
                },
              ),
            ],
          );
  }
}
