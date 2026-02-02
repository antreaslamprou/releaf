import 'package:flutter/material.dart';
import 'package:releaf/components/single_post.dart';
import 'package:releaf/pages/template_single_page.dart';
import 'package:releaf/utils/conversions.dart';

class PostsGrid extends StatelessWidget {
  const PostsGrid({super.key, required this.posts});

  // Data holders
  final Map<String, dynamic>? posts;

  // Shows the user badges if available, otherwise a warning message
  @override
  Widget build(BuildContext context) {
    final entries = posts?.entries.toList() ?? [];
    return GridView.builder(
      shrinkWrap: true,
      itemCount: entries.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemBuilder: (context, index) {
        final item = entries[index].value;
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  TemplateSinglePage(body: SinglePost(postData: item)),
            ),
          ),
          child: Image.memory(
            Conversions.baseToImage(item['image']),
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
