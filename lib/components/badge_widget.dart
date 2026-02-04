import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/providers/theme_provider.dart';

class BadgeWidget extends StatelessWidget {
  const BadgeWidget({
    super.key,
    required this.number,
    this.progress,
    this.title,
  });

  // Data holders
  final num number;
  final num? progress;
  final String? title;

  // Shows the badge
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Shows badge
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            border: Border.all(
              color: progress == null
                  ? context.watch<ThemeProvider>().primaryColor
                  : progress! >= 3
                  ? const Color.fromARGB(255, 255, 215, 0)
                  : progress! == 2
                  ? const Color.fromARGB(255, 205, 127, 50)
                  : progress! == 1
                  ? const Color.fromARGB(255, 205, 127, 50)
                  : Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Image.asset(
              'assets/images/sdg$number.png',
              width: 75,
              color: progress == null
                  ? null
                  : progress! < 1
                  ? Colors.grey
                  : null,
            ),
          ),
        ),
        if (progress != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
            child: Row(
              spacing: 2,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/badge.png',
                  width: 20,
                  color: progress! >= 1
                      ? const Color.fromARGB(255, 205, 127, 50)
                      : Colors.grey,
                  fit: BoxFit.cover,
                ),
                Image.asset(
                  'assets/images/badge.png',
                  width: 20,
                  color: progress! >= 2
                      ? const Color.fromARGB(255, 192, 192, 192)
                      : Colors.grey,
                  fit: BoxFit.cover,
                ),
                Image.asset(
                  'assets/images/badge.png',
                  width: 20,
                  color: progress! >= 3
                      ? const Color.fromARGB(255, 255, 215, 0)
                      : Colors.grey,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
        // Shows title
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              title!,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        // Shows description
        if (progress != null)
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
