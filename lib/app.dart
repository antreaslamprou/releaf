import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/pages/base_page.dart';
import 'package:releaf/pages/login_page.dart';
import 'package:releaf/pages/register_page.dart';
import 'package:releaf/pages/splash_page.dart';
import 'package:releaf/providers/text_scale.dart';
import 'package:releaf/providers/theme_provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: Provider.of<TextScaleProvider>(context).textScale),
      child: MaterialApp(
        title: 'ReLeaf',
        theme: Provider.of<ThemeProvider>(context).themeData,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => SplashPage(),
          '/home': (context) => BasePage(),
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
        },
      ),
    );
  }
}
