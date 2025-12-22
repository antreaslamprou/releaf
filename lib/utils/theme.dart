import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: Colors.green,
    surface: const Color.fromARGB(240, 255, 255, 255),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: Colors.green,
  ),
);

TextTheme normalText = TextTheme(
  bodySmall: TextStyle(fontSize: 16),
  bodyMedium: TextStyle(fontSize: 18),
  displayMedium: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
  displayLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
);
