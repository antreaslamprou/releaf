import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:releaf/components/avatar_widget.dart';
import 'package:releaf/components/bottom_modal.dart';
import 'package:releaf/components/comments_section.dart';
import 'package:releaf/controllers/comments_controller.dart';
import 'package:releaf/controllers/likes_controller.dart';
import 'package:releaf/controllers/saves_controller.dart';
import 'package:releaf/pages/profile_page.dart';
import 'package:releaf/services/post_service.dart';
import 'package:releaf/services/report_service.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/conversions.dart';
import 'package:releaf/utils/snackbar.dart';

class Post extends StatefulWidget {
  const Post({super.key, required this.postData, this.isReportable = true});

  // Widget parameters for the post, like and save button
  final Map<dynamic, dynamic> postData;
  final bool isReportable;

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  // Get important user defined services for fetching/altering user, post and report data
  final _userService = UserService();
  final _postService = PostService();
  final _reportService = ReportService();

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

    final userDataTemp = await _userService.getUserData(uid: userId);

    final isLikedTemp = await _postService.getUserLiked(postId);
    final postData = await _postService.getPostById(postId);
    final likesTemp = postData['likes'] != null ? postData['likes'].length : 0;

    final isSaved = await _postService.getUserSaved(postId);

    if (!mounted) return;
    setState(() {
      userData = userDataTemp;

      likesController = getLikesController(
        postData['id'],
        initialCount: likesTemp,
        initialLiked: isLikedTemp,
      );

      savesController = getSavesController(postId, initialSaved: isSaved);
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

  // Report functionality
  void createReport(ReportType type) async {
    final userId = _userService.getUserUID();
    final isOkay = await _reportService.createReport(
      userId,
      widget.postData['id'],
      type,
    );
    if (!mounted) return;
    Snackbar.show(
      context,
      isOkay ? 'Report Created!' : 'There is an existing report.',
    );
  }

  // Creates a report entity in the database for the current post
  void reportPost(BuildContext context) async {
    final List<BottomAction> actions = [
      BottomAction(
        icon: Icons.local_police,
        label: 'Violence',
        onTap: () => createReport(ReportType.violence),
      ),
      BottomAction(
        icon: Icons.person_pin,
        label: 'Nudity',
        onTap: () => createReport(ReportType.nudity),
      ),
      BottomAction(
        icon: Icons.plumbing,
        label: 'Drugs',
        onTap: () => createReport(ReportType.drugs),
      ),
      BottomAction(
        icon: Icons.pest_control,
        label: 'False Task Completion',
        onTap: () => createReport(ReportType.falseTask),
      ),
      BottomAction(
        icon: Icons.flag,
        label: 'Other',
        onTap: () => createReport(ReportType.other),
      ),
    ];

    showBottomActions(context, actions);
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
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ProfilePage(userId: userData!["id"]),
                          ),
                        ),
                        child: Row(
                          children: [
                            AvatarWidget(
                              key: ValueKey(userData!['avatar']),
                              avatarType: userData!['avatar_type'],
                              avatarImage: userData!['avatar'],
                              radius: 20,
                            ),
                            SizedBox(width: 10),
                            Text(
                              userData!["username"],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            if (widget.isReportable)
                              IconButton(
                                onPressed: () => reportPost(context),
                                icon: Icon(Icons.flag_rounded),
                              ),
                          ],
                        ),
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
                          Obx(() {
                            return Text(likesController.count.value.toString());
                          }),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Like button
                          Obx(() {
                            final isLiked = likesController.isLiked.value;
                            return TextButton(
                              onPressed: toggleLikes,
                              child: Row(
                                children: [
                                  Icon(
                                    isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(isLiked ? 'Liked' : 'Like'),
                                ],
                              ),
                            );
                          }),

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
                          Obx(() {
                            final isSaved = savesController.isSaved.value;
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
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: commentsController.isCommentsOpen,
                builder: (_, isCommentsOpen, _) {
                  return AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    child: isCommentsOpen
                        ? FractionallySizedBox(
                            widthFactor: 1,
                            child: CommentsSection(
                              postId: widget.postData['id'],
                            ),
                          )
                        : const Card(
                            child: FractionallySizedBox(widthFactor: 1),
                          ),
                  );
                },
              ),
            ],
          );
  }
}
