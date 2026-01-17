import 'package:flutter/material.dart';
import 'package:road_assist/core/theme/app_palette.dart';

import 'app_theme_type.dart';

class AppTheme {
  // static final ThemeData lightBlue = ThemeData(
  //   colorScheme: ColorScheme.fromSeed(
  //     seedColor: const Color.fromRGBO(188, 214, 236, 1),
  //     brightness: Brightness.light,
  //   ),
  //   useMaterial3: true,
  // );

  // static final ThemeData lightGreen = ThemeData(
  //   colorScheme: ColorScheme.fromSeed(
  //     seedColor: Colors.green,
  //     brightness: Brightness.light,
  //   ),
  //   useMaterial3: true,
  // );

  // static final ThemeData darkBlue = ThemeData(
  //   colorScheme: ColorScheme.fromSeed(
  //     seedColor: Colors.blue,
  //     brightness: Brightness.dark,
  //   ),
  //   useMaterial3: true,
  // );

  // static final ThemeData darkPurple = ThemeData(
  //   colorScheme: ColorScheme.fromSeed(
  //     seedColor: Colors.deepPurple,
  //     brightness: Brightness.dark,
  //   ),
  //   useMaterial3: true,
  // );

  static final _lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppPalette.blue1,
      onPrimary: Colors.white,
      error: AppPalette.red,
      onError: Colors.white,
      secondary: AppPalette.dark1,
      onSecondary: Colors.white,
      surface: AppPalette.blue1,
      onSurface: Colors.white,
    ),
  );
  // static final _darkTheme =

  static ThemeData themByType(AppThemeType type) {
    switch (type) {
      // case AppThemeType.dark:
      //   // return _darkTheme;
      //   return _darkTheme;
      case AppThemeType.light:
        return _lightTheme;
      default:
        return _lightTheme;
    }
  }
}
