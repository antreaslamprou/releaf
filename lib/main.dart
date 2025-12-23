import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/providers/daily_post_provider.dart';
import 'package:releaf/providers/text_scale.dart';
import 'package:releaf/providers/theme_provider.dart';
import 'package:releaf/providers/avatar_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  final textScaleProvider = TextScaleProvider();
  await textScaleProvider.loadTextScale();

  final avatarProvider = AvatarProvider();
  await avatarProvider.loadAvatar();

  final dailyPostProvider = DailyPostProvider();
  await dailyPostProvider.loadDailyPost();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<TextScaleProvider>.value(
          value: textScaleProvider,
        ),
        ChangeNotifierProvider<AvatarProvider>.value(value: avatarProvider),
        ChangeNotifierProvider<DailyPostProvider>.value(
          value: dailyPostProvider,
        ),
      ],
      child: const App(),
    ),
  );
}
