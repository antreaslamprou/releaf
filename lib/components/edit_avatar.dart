import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/extensions/text_theme_x.dart';
import 'package:releaf/providers/avatar_provider.dart';
import 'package:releaf/providers/theme_provider.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:releaf/services/user_service.dart';
import 'package:get/get.dart';
import 'package:releaf/utils/snackbar.dart';
import 'package:releaf/utils/theme.dart';

class EditAvatar extends StatefulWidget {
  const EditAvatar({super.key});

  @override
  State<EditAvatar> createState() => _EditAvatarState();
}

class _EditAvatarState extends State<EditAvatar> {
  // Get important user defined services for fetching/altering user and avatar data
  final _userService = UserService();
  final _fluttermojiFunctions = FluttermojiFunctions();

  @override
  void initState() {
    super.initState();

    // Creates the fluttermoji controller
    Get.put(FluttermojiController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  // Deletes the fluttermoji controller
  @override
  void dispose() {
    Get.delete<FluttermojiController>();

    super.dispose();
  }

  // Loads the data for the current user
  void loadData() async {
    final userData = await _userService.getUserData();
    if (userData['avatar_type'] == 'Avatar') {
      _fluttermojiFunctions.decodeFluttermojifromString(userData['avatar']);
    }
  }

  Future<void> saveAvatar(BuildContext context) async {
    final encoded = await _fluttermojiFunctions.encodeMySVGtoString();
    if (!mounted) return;
    Snackbar.show(context, 'Avatar saved!');
    context.read<AvatarProvider>().uploadAvatar(encoded);
  }

  // Show the edit profile page with the current user data
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: FluttermojiCircleAvatar(
            radius: 55,
            backgroundColor: Colors.transparent,
          ),
        ),
        FluttermojiSaveWidget(
          onTap: () => saveAvatar(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.save), SizedBox(width: 5), Text('Save')],
            ),
          ),
        ),
        SizedBox(height: 15),
        Expanded(
          child: FluttermojiCustomizer(
            autosave: false,
            theme: context.read<ThemeProvider>().themeData == darkMode
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
