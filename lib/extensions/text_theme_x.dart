import 'package:flutter/material.dart';

extension TextThemeX on BuildContext {
  TextTheme get text => Theme.of(this).textTheme;
}
