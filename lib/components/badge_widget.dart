import 'package:flutter/material.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class BadgeWidget extends StatelessWidget {
  const BadgeWidget({
    super.key,
    required this.number,
    required this.progress,
    required this.title,
  });

  // Data holders
  final num number;
  final num progress;
  final String title;

  // Shows the badge
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Shows badge
        Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/images/badge.png',
              width: 100,
              color: progress >= 3
                  ? const Color.fromARGB(255, 255, 215, 0)
                  : progress == 2
                  ? const Color.fromARGB(255, 192, 192, 192)
                  : progress == 1
                  ? const Color.fromARGB(255, 205, 127, 50)
                  : Colors.grey[700],
              fit: BoxFit.cover,
            ),
            Text(
              number.toString(),
              style: context.text.titleLarge?.copyWith(color: Colors.black),
            ),
          ],
        ),
        SizedBox(height: 10),
        // Shows title
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        // Shows description
        Text(
          progress == 0
              ? 'Complete the task to achieve the badge!'
              : progress == 1
              ? 'Complete the task two times to achieve the badge'
              : progress == 2
              ? 'Complete the task three times to achieve the badge'
              : 'You have gathered all badges for this type!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
