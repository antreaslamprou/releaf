import 'package:flutter/material.dart';
import 'package:releaf/services/post_service.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/utils/conversions.dart';
import 'package:releaf/utils/snackbar.dart';

class CommentsSection extends StatefulWidget {
  const CommentsSection({super.key, required this.postId});

  // Widget parameters used to fetch correctly the post comments
  final String postId;

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  // Get important user defined services for fetching/altering user and post data
  final _userService = UserService();
  final _postService = PostService();

  // Data holders and state variables
  late TextEditingController _commentController;
  List<Map<dynamic, dynamic>> comments = [];
  static const maxCommentsCount = 5;
  int displayCommentsCount = maxCommentsCount;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _commentController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();

    super.dispose();
  }

  // Fetches all data regarding the current post comments
  Future<void> init() async {
    final commentsTemp = await _postService.getComments(widget.postId);

    List<Map<dynamic, dynamic>> fullData = [];

    for (final userComment in commentsTemp) {
      final userId = userComment.keys.first.split('_')[0];
      final commentText = userComment[userComment.keys.first];

      final userData = await _userService.getUserDataById(userId);

      fullData.add({'comment': commentText, 'user': userData});
    }

    setState(() {
      comments = fullData;
      isLoading = false;
    });
  }

  Future<void> addComment() async {
    final isOkay = await _postService.postComment(
      widget.postId,
      _commentController.text,
    );

    if (!mounted) return;
    if (isOkay) {
      init();
      _commentController.clear();
      Snackbar.show(context, 'Comment Posted!');
    } else {
      Snackbar.show(context, 'Error with posting comment');
    }
  }

  void showMoreComments() {
    setState(() {
      displayCommentsCount = (displayCommentsCount + maxCommentsCount).clamp(
        0,
        comments.length,
      );
    });
  }

  // Shows the comments section of a post
  @override
  Widget build(BuildContext context) {
    final displayedComments = comments.take(displayCommentsCount).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      Text(
                        'Comments',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      comments.isEmpty
                          ? Text('No comments yet. Be the first to comment!')
                          : ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: displayedComments.length,
                              itemBuilder: (_, index) {
                                final item = displayedComments[index];
                                final comment = item['comment'];
                                final user =
                                    item['user'] as Map<String, dynamic>;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, // aligns avatar to top
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundImage: MemoryImage(
                                          Conversions.baseToImage(
                                            user['avatar'],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user['full_name'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              comment,
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                      if (displayCommentsCount < comments.length)
                        TextButton(
                          onPressed: showMoreComments,
                          child: const Text('Show more'),
                        ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          labelText: 'Comment',
                          suffixIcon: IconButton(
                            onPressed: addComment,
                            icon: Icon(Icons.send),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
