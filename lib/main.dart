import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/providers/avatar_provider.dart';
import 'package:releaf/providers/daily_post_provider.dart';
import 'package:releaf/providers/text_scale_provider.dart';
import 'package:releaf/providers/theme_provider.dart';
import 'app.dart';

void main() async {
  // Ensures Firebase initializes first
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Create all providers
  final themeProvider = ThemeProvider();
  final textScaleProvider = TextScaleProvider();
  final avatarProvider = AvatarProvider();
  final dailyPostProvider = DailyPostProvider();

  // Run app wrapped in the providers values
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
