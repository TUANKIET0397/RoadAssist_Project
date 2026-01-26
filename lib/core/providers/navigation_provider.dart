import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider quản lý hiển thị navigation bar
/// false = ẩn navigation bar
final navigationVisibilityProvider =
    StateNotifierProvider<NavigationVisibilityNotifier, bool>((ref) {
  return NavigationVisibilityNotifier();
});

class NavigationVisibilityNotifier extends StateNotifier<bool> {
  NavigationVisibilityNotifier() : super(true);

  void show() => state = true;
  void hide() => state = false;
}
