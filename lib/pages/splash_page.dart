import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/providers/daily_post_provider.dart';
import 'package:releaf/providers/text_scale_provider.dart';
import 'package:releaf/services/user_service.dart';
import 'package:releaf/providers/avatar_provider.dart';
import 'package:releaf/providers/theme_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

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

  // Redirect to the correct path depending on wether the user is logged in or
  // not, if the user is logged in, initialize the providers
  Future<void> init() async {
    final uid = _userService.getUserUID();

    // User comes from log out or user didnt log in yet
    if (uid.isEmpty) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // User comes from log in
    final textScaleProvider = Provider.of<TextScaleProvider>(
      context,
      listen: false,
    );
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final dailyPostProvider = Provider.of<DailyPostProvider>(
      context,
      listen: false,
    );
    final avatarProvider = Provider.of<AvatarProvider>(context, listen: false);

    await textScaleProvider.loadTextScale();
    await themeProvider.loadTheme();
    await dailyPostProvider.loadDailyPost();
    await avatarProvider.loadAvatar();

    await _userService.checkHotstreaks();

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  // Show the ReLeaf logo while the process is done in the background
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
