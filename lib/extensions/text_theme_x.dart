import 'package:flutter/material.dart';

// Helps to write cleaner code in relation to custom texts
extension TextThemeX on BuildContext {
  TextTheme get text => Theme.of(this).textTheme;
}
