import 'package:flutter/material.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class TemplateSinglePage extends StatelessWidget {
  const TemplateSinglePage({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final Widget body;

  // // Loads the user saved posts
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: context.text.titleSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(padding: EdgeInsets.all(15), child: body),
    );
  }
}
