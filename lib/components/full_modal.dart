import 'package:flutter/material.dart';

// Shows the bottom modal sheet, takes the a list of bottom actions, which contain
// Icon, label, functionality and optional red color
Future<void> showFullModal(
  BuildContext context,
  String title,
  String description,
  String buttonText,
  VoidCallback onTap,
) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onTap();
            },
            child: Text(buttonText),
          ),
        ],
      );
    },
  );
}
