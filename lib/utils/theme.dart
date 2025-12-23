import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  textTheme: normalTextTheme,
  navigationBarTheme: NavigationBarThemeData(
    labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
      // final base = normalTextTheme.labelSmall!;
      // if (states.contains(WidgetState.selected)) {
      //   return base.copyWith(fontWeight: FontWeight.bold);
      // }
      // return base;
      return normalTextTheme.labelSmall!;
    }),
  ),
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: Colors.green,
    surface: const Color.fromARGB(240, 245, 245, 245),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  textTheme: normalTextTheme,
  navigationBarTheme: NavigationBarThemeData(
    labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
      // final base = normalTextTheme.labelSmall!;
      // if (states.contains(WidgetState.selected)) {
      //   return base.copyWith(fontWeight: FontWeight.bold);
      // }
      // return base;
      return normalTextTheme.labelSmall!;
    }),
  ),
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: Colors.green,
  ),
);

TextTheme normalTextTheme = TextTheme(
  labelSmall: TextStyle(
    fontSize: 12,
    height: 0.1,
  ), // Bottom Navigation (Hide Text)
  labelMedium: TextStyle(
    fontSize: 14,
    color: Colors.green,
    fontWeight: FontWeight.bold,
  ), // Links
  bodyMedium: TextStyle(fontSize: 14), // Body
  bodyLarge: TextStyle(fontSize: 14), // Form Fields
  titleSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Header 3
  titleMedium: TextStyle(fontSize: 30, fontWeight: FontWeight.bold), // Header 2
  titleLarge: TextStyle(fontSize: 35, fontWeight: FontWeight.bold), // Header 1
);
