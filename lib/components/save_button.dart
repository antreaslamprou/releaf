import 'package:flutter/material.dart';
import 'package:releaf/services/post_service.dart';
import 'package:releaf/utils/snackbar.dart';

class SaveButton extends StatefulWidget {
  const SaveButton({super.key, required this.postId});

  // Widget variable with the post id
  final String postId;

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  // Get important user defined services for fetching/altering post data
  final PostService _postService = PostService();

  // Initial value of save status
  bool saved = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getSavedStatus();
    });
  }

  // Fetches whether the user already saved the post or not
  void getSavedStatus() async {
    final isSavedTemp = await _postService.getUserSaved(widget.postId);
    setState(() {
      saved = isSavedTemp;
    });
  }

  // Toogles the save functionality to show the changes visually and update the
  // database
  void toggleSave() async {
    if (await _postService.savePost(widget.postId)) {
      setState(() {
        saved = !saved;
      });
      return;
    }
    if (!mounted) return;
    Snackbar.show(context, 'Error with liking this post!');
  }

  // Shows the save button
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
      ),
      onPressed: toggleSave,
    );
  }
}
