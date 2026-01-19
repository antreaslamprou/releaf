import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/extensions/text_theme_x.dart';
import 'package:releaf/providers/avatar_provider.dart';
import 'package:releaf/providers/theme_provider.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:releaf/utils/snackbar.dart';

class EditAvatar extends StatelessWidget {
  const EditAvatar({super.key});

  // Function that updates UI
  Future<void> saveAvatar(BuildContext context) async {
    context.read<AvatarProvider>().uploadAvatar();
    Snackbar.show(context, 'Avatar saved!');
  }

  // Show the edit profile page with the current user data
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: FluttermojiCircleAvatar(
            radius: 65,
            backgroundColor: Colors.transparent,
          ),
        ),
        ElevatedButton(
          onPressed: () => saveAvatar(context),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(Icons.save), SizedBox(width: 5), Text('Save')],
          ),
        ),
        SizedBox(height: 15),
        Expanded(
          child: FluttermojiCustomizer(
            autosave: false,
            theme: context.read<ThemeProvider>().themeMode == ThemeMode.dark
                ? FluttermojiThemeData(
                    primaryBgColor: Colors.grey.shade900,
                    secondaryBgColor: Colors.grey.shade700,
                    labelTextStyle: context.text.titleSmall,
                  )
                : FluttermojiThemeData(labelTextStyle: context.text.titleSmall),
          ),
        ),
      ],
    );
  }
}
