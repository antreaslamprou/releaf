import 'package:flutter/material.dart';

// Light theme
ThemeData lightTheme(Color primaryColor) {
  return ThemeData(
    brightness: Brightness.light,
    textTheme: normalTextTheme(primaryColor),
    // Hide bottom navbar text
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: WidgetStateProperty.resolveWith(
        (_) => normalTextTheme(primaryColor).labelSmall!,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: primaryColor,
    ),
  );
}

// Dark theme
ThemeData darkTheme(Color primaryColor) {
  return ThemeData(
    brightness: Brightness.dark,
    textTheme: normalTextTheme(primaryColor),
    // Hide bottom navbar text
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: WidgetStateProperty.resolveWith(
        (_) => normalTextTheme(primaryColor).labelSmall!,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: primaryColor,
    ),
  );
}

// Normal text size theme
TextTheme normalTextTheme(Color linksColor) {
  return TextTheme(
    labelSmall: TextStyle(
      fontSize: 12,
      height: 0.1,
    ), // Bottom Navigation (Hide Text)
    labelMedium: TextStyle(
      fontSize: 14,
      color: linksColor,
      fontWeight: FontWeight.bold,
    ), // Links
    bodyMedium: TextStyle(fontSize: 14), // Body
    bodyLarge: TextStyle(fontSize: 14), // Form Fields
    titleSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ), // Header 3
    titleMedium: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
    ), // Header 2
    titleLarge: TextStyle(
      fontSize: 35,
      fontWeight: FontWeight.bold,
    ), // Header 1
  );
}
