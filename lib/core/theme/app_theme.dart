import 'package:flutter/material.dart';
import 'package:road_assist/core/theme/app_palette.dart';

import 'app_theme_type.dart';

class AppTheme {
  static final _lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Nunito',
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppPalette.blue1,
      onPrimary: Colors.white,
      error: AppPalette.red,
      onError: Colors.white,
      secondary: AppPalette.dark1,
      onSecondary: Colors.white,
      surface: AppPalette.bgColors[0],
      onSurface: Colors.white,
    ),
  );

  static ThemeData themByType(AppThemeType type) {
    switch (type) {
      case AppThemeType.light:
        return _lightTheme;
      default:
        return _lightTheme;
    }
  }
}
