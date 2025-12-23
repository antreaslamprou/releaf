import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/pages/base_page.dart';
import 'package:releaf/pages/login_page.dart';
import 'package:releaf/pages/register_page.dart';
import 'package:releaf/pages/splash_page.dart';
import 'package:releaf/providers/avatar_provider.dart';
import 'package:releaf/providers/daily_post_provider.dart';
import 'package:releaf/providers/text_scale_provider.dart';
import 'package:releaf/providers/theme_provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TextScaleProvider()),
        ChangeNotifierProvider(create: (_) => AvatarProvider()),
        ChangeNotifierProvider(create: (_) => DailyPostProvider()),
      ],
      child: Consumer2<ThemeProvider, TextScaleProvider>(
        builder: (context, themeProvider, textScaleProvider, _) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: textScaleProvider.textScale),
            child: MaterialApp(
              title: 'ReLeaf',
              theme: themeProvider.themeData,
              initialRoute: '/splash',
              routes: {
                '/splash': (_) => const SplashPage(),
                '/home': (_) => const BasePage(),
                '/login': (_) => const LoginPage(),
                '/register': (_) => const RegisterPage(),
              },
            ),
          );
        },
      ),
    );
  }
}
