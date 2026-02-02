import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/extensions/text_theme_x.dart';
import 'package:releaf/pages/base_page.dart';
import 'package:releaf/pages/login_page.dart';
import 'package:releaf/pages/no_network_page.dart';
import 'package:releaf/providers/daily_post_provider.dart';
import 'package:releaf/providers/text_scale_provider.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/providers/avatar_provider.dart';
import 'package:releaf/providers/theme_provider.dart';
import 'package:releaf/utils/snackbar.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, this.deleteUser = false});

  final bool deleteUser;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  // Get important user defined services for fetching/altering user data
  final _userService = UserService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // Redirect to the correct path depending on wether the user is logged in or
  // not, if the user is logged in, initialize the providers
  Future<void> init() async {
    if (!kIsWeb) {
      // App doesnt have access to network
      bool isNetworkConnected = await hasInternet();
      if (!isNetworkConnected) {
        if (!mounted) return;
        Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => NoNetworkPage()));
        return;
      }
    }

    // Get providers
    if (!mounted) return;
    final textScaleProvider = context.read<TextScaleProvider>();
    final themeProvider = context.read<ThemeProvider>();
    final dailyPostProvider = context.read<DailyPostProvider>();
    final avatarProvider = context.read<AvatarProvider>();

    //User needs to be deleted
    if (widget.deleteUser) {
      final userService = UserService();
      await userService.deleteUser();
      if (!mounted) return;
      Snackbar.show(context, 'Account deleted.');
    }

    // User comes from log out / user didnt log in yet / user deleted
    final uid = _userService.getUserUID();
    if (uid.isEmpty) {
      context.read<TextScaleProvider>().reset();
      context.read<DailyPostProvider>().reset();
      context.read<AvatarProvider>().reset();
      context.read<ThemeProvider>().reset();

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      return;
    }

    // User comes from log in, initialize providers
    await textScaleProvider.loadTextScale();
    await themeProvider.loadTheme();
    await dailyPostProvider.loadDailyPost();
    await avatarProvider.loadAvatar();

    await _userService.checkHotstreaks();

    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => BasePage()));
  }

  // Show the ReLeaf logo while the process is done in the background
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10),
            Text('ReLeaf', style: context.text.titleMedium),
          ],
        ),
      ),
    );
  }
}
