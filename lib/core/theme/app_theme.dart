import 'package:flutter/material.dart';

import 'app_theme_type.dart';

class AppTheme {
  static final ThemeData lightBlue = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromRGBO(188, 214, 236, 1),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  static final ThemeData lightGreen = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  static final ThemeData darkBlue = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  static final ThemeData darkPurple = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  static ThemeData byType(AppThemeType type) {
    switch (type) {
      case AppThemeType.lightBlue:
        return lightBlue;
      case AppThemeType.lightGreen:
        return lightGreen;
      case AppThemeType.darkBlue:
        return darkBlue;
      case AppThemeType.darkPurple:
        return darkPurple;
    }
  }
}
