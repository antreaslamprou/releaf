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

InputDecoration inputDecoration({
  required String label,
  IconData? icon,
  String? hint,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: icon != null ? Icon(icon) : null,

    filled: true,
    fillColor: Colors.grey.shade100,

    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Colors.green.shade300,
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.green,
        width: 2,
      ),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.red,
      ),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.red,
        width: 2,
      ),
    ),
  );
}