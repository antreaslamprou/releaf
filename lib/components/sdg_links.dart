import 'package:flutter/material.dart';
import 'package:releaf/components/badge_widget.dart';
import 'package:releaf/utils/web_link.dart';

class SdgLinks extends StatelessWidget {
  const SdgLinks({super.key});

  // Shows the user badges if available, otherwise a warning message
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: 17,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        return Container(
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () => WebLink.open(
              context,
              'https://sdgs.un.org/goals/goal${index + 1}',
            ),
            child: BadgeWidget(number: index + 1),
          ),
        );
      },
    );
  }
}
