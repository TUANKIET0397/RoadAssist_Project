import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme_type.dart';

final appThemeProvider = StateProvider<AppThemeType>((ref) {
  return AppThemeType.lightBlue; // default
});
