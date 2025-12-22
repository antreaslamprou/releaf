import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:releaf/utils/snackbar.dart';
import 'package:releaf/utils/theme.dart';
import 'package:releaf/providers/theme_provider.dart';
import 'package:releaf/services/user_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final userService = UserService();

  void toggleTheme(bool value) {
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
  }

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
                Text('This action cannot be undone.'),
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
              child: Text('Delete'),
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

  void deleteAccount() async {
    final isOkay = await userService.deleteUser();

    if (!mounted) return;
    if (!isOkay) return Snackbar.show(context, 'Error With Deleting Account');

    Navigator.pushReplacementNamed(context, '/login');
    Snackbar.show(context, 'Account deleted.');
  }

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adjust your preferences below:',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Theme', style: TextStyle(fontWeight: FontWeight.bold)),
              FlutterSwitch(
                value:
                    Provider.of<ThemeProvider>(context).themeData == darkMode,
                activeIcon: Icon(Icons.nightlight_round, color: Colors.black),
                activeText: 'Dark',
                activeColor: Colors.green.shade900,
                activeTextColor: Colors.white,
                inactiveIcon: Icon(Icons.wb_sunny),
                inactiveColor: Colors.green.shade300,
                inactiveText: 'Light',
                inactiveTextColor: Colors.black,
                showOnOff: true,
                width: 80,
                onToggle: toggleTheme,
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
                  child: const Text(
                    'Have a suggestion for a potential task?\nSend us an email throught this link!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: showDeleteAccountDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.black,
                  ),
                  child: Text('Delete Account'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
