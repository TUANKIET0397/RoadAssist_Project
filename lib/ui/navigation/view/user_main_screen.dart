import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/navigation/configs/user_bottom_nav.dart';
import 'package:road_assist/ui/navigation/widgets/slanted_animated_bottom_bar.dart';
import 'package:road_assist/core/providers/navigation_provider.dart';

class UserMainScreen extends ConsumerWidget {
  final Widget child;

  const UserMainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showNavigation = ref.watch(navigationVisibilityProvider);

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: showNavigation
          ? SlantedAnimatedBottomBar(
              items: userBottomNavItems,
              defaultIndex: 2,
            )
          : null,
    );
  }
}
