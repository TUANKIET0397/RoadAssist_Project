import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/theme/app_theme_type.dart';

final appThemeProvider = StateProvider<AppThemeType>((ref) {
  return AppThemeType.light; // default
});
