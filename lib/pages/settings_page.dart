import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:releaf/providers/text_scale_provider.dart';
import 'package:releaf/utils/snackbar.dart';
import 'package:releaf/utils/theme.dart';
import 'package:releaf/providers/theme_provider.dart';
import 'package:releaf/services/user_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Get important user defined services for fetching/altering user data
  final _userService = UserService();

  // Call the toogle theme on switch tap
  void toggleTheme(bool value) {
    context.read<ThemeProvider>().toggleTheme();
  }

  // Call the toogle text scale on switch tap
  void toggleTextScale(bool value) {
    context.read<TextScaleProvider>().toogleTextScale();
  }

  // Shows a dialog with the delete account warning, gives the option to proceed
  // or cancel
  Future<void> showDeleteAccountDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete your account?'),
                Text('This action cannot be reverted.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                Navigator.of(context).pop();
                deleteAccount();
              },
            ),
          ],
        );
      },
    );
  }

  // Deletes all user related data and resets the providers
  void deleteAccount() async {
    final isOkay = await _userService.deleteUser();

    if (!mounted) return;
    if (!isOkay) return Snackbar.show(context, 'Error With Deleting Account');

    Navigator.pushReplacementNamed(context, '/splash');
    Snackbar.show(context, 'Account deleted.');
  }

  // Navigates the user to their default email application with the receiver
  // email and subject already filled
  void sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'antreaslamprou12@gmail.com',
      queryParameters: {'subject': 'ReLeaf - User Reccomended Task'},
    );

    try {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      Snackbar.show(context, 'Error With Opening Email');
    }
  }

  // Shows the settings page
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Adjust your preferences below:'),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Theme', style: TextStyle(fontWeight: FontWeight.bold)),
              FlutterSwitch(
                value: context.watch<ThemeProvider>().themeData == darkMode,
                activeIcon: Icon(Icons.nightlight_round, color: Colors.black),
                activeColor: Colors.green.shade900,
                activeTextColor: Colors.white,
                activeText: 'Dark',
                inactiveIcon: Icon(Icons.wb_sunny),
                inactiveColor: Colors.green.shade300,
                inactiveTextColor: Colors.black,
                inactiveText: 'Light',
                showOnOff: true,
                width: 80,
                onToggle: toggleTheme,
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Large Text', style: TextStyle(fontWeight: FontWeight.bold)),
              FlutterSwitch(
                value: context.watch<TextScaleProvider>().scaleFactor != 1,
                activeIcon: Icon(Icons.check, color: Colors.black),
                activeColor: Colors.green.shade900,
                activeTextColor: Colors.white,
                activeText: 'On',
                inactiveIcon: Icon(Icons.close, color: Colors.black),
                inactiveColor: Colors.green.shade300,
                inactiveTextColor: Colors.black,
                inactiveText: 'Off',
                showOnOff: true,
                width: 80,
                onToggle: toggleTextScale,
              ),
            ],
          ),
          SizedBox(height: 25),
          FractionallySizedBox(
            widthFactor: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    sendEmail();
                  },
                  child: Text(
                    'Have a suggestion for a potential task?\nSend us an email throught this link!',
                    textAlign: TextAlign.center,
                    style: context.text.labelMedium,
                  ),
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: showDeleteAccountDialog,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.black,
                  ),
                  child: Text('DELETE ACCOUNT'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
