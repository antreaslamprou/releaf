import 'package:flutter/material.dart';

// Structure of each bottom request
class BottomAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isRed;

  BottomAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isRed = false,
  });
}

// Shows the bottom modal sheet, takes the a list of bottom actions, which contain
// Icon, label, functionality and optional red color
void showBottomActions(BuildContext context, List<BottomAction> actions) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 15),
            for (final action in actions)
              ListTile(
                    leading: Icon(
                      action.icon,
                      color: action.isRed ? Colors.red : null,
                    ),
                    title: Text(
                      action.label,
                      style: TextStyle(color: action.isRed ? Colors.red : null),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      action.onTap();
                    },
                  )
                  as Widget,
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    },
  );
}
