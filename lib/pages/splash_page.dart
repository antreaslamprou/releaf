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
  final userService = UserService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  Future<void> init() async {
    final uid = userService.getUserUID();

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

    if (uid == '') {
      textScaleProvider.reset();
      themeProvider.reset();
      dailyPostProvider.reset();
      avatarProvider.reset();

      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    await textScaleProvider.loadTextScale();
    await themeProvider.loadTheme();
    await dailyPostProvider.loadDailyPost();
    await avatarProvider.loadAvatar();

    await userService.checkHotstreaks();

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

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
