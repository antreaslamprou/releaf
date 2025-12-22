import 'package:flutter/material.dart';
import 'package:releaf/services/post_service.dart';

class SaveButton extends StatefulWidget {
  const SaveButton({
    super.key,
    required this.postId,
    required this.initiallySaved,
  });

  final String postId;
  final bool initiallySaved;

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  PostService postService = PostService();
  late bool saved;

  @override
  void initState() {
    super.initState();
    saved = widget.initiallySaved;
  }

  void toggleSave() async {
    setState(() {
      saved = !saved;
    });
    // Save post onto account
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
