import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';
import 'package:releaf/pages/base_page.dart';
import 'package:releaf/pages/login_page.dart';
import 'package:releaf/pages/no_network_page.dart';
import 'package:releaf/pages/register_page.dart';
import 'package:releaf/pages/splash_page.dart';
import 'package:releaf/providers/text_scale_provider.dart';
import 'package:releaf/providers/theme_provider.dart';
import 'package:releaf/utils/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  // Return the widget based on the route, and the size of the text besed on
  // the text scaler provider multiplier
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: context.watch<TextScaleProvider>().textScale),
      child: KeyboardDismisser(
        gestures: [GestureType.onTap],
        child: MaterialApp(
          title: 'ReLeaf',
          debugShowCheckedModeBanner: false,
          theme: lightTheme(context.watch<ThemeProvider>().primaryColor),
          darkTheme: darkTheme(context.watch<ThemeProvider>().primaryColor),
          themeMode: context.watch<ThemeProvider>().themeMode,
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashPage(),
            '/no-network': (context) => const NoNetworkPage(),
            '/home': (context) => const BasePage(),
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
          },
        ),
      ),
    );
  }
}
