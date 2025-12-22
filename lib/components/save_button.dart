import 'package:flutter/material.dart';
import 'package:releaf/services/post_service.dart';
import 'package:releaf/utils/snackbar.dart';

class SaveButton extends StatefulWidget {
  const SaveButton({super.key, required this.postId});

  final String postId;

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  PostService postService = PostService();
  bool saved = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getSavedStatus();
    });
  }

  void getSavedStatus() async {
    final isSavedTemp = await postService.getUserSaved(widget.postId);
    setState(() {
      saved = isSavedTemp;
    });
  }

  void toggleSave() async {
    if (await postService.savePost(widget.postId)) {
      setState(() {
        saved = !saved;
      });
      return;
    }
    if (!mounted) return;
    Snackbar.show(context, 'Error with liking this post!');
  }

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
