import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:road_assist/core/errors/no_internet_screen.dart';
import 'package:road_assist/core/network/network_service.dart';
import 'package:road_assist/core/network/network_status.dart';
import 'package:road_assist/core/routes/app_routes.dart';
import 'package:road_assist/core/routes/route_config.dart';
import 'package:road_assist/core/theme/app_theme.dart';
import 'package:road_assist/core/theme/theme_provider.dart';
import 'package:road_assist/core/providers/navigation_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  void _updateNavbarVisibility(WidgetRef ref, GoRouter router) {
    try {
      final location = router.routerDelegate.currentConfiguration.uri.path;
      debugPrint('📍 Current route: $location');

      if (RouteConfig.shouldHideNavbar(location)) {
        debugPrint('🔒 Hiding navbar for: $location');
        ref.read(navigationVisibilityProvider.notifier).hide();
      } else if (RouteConfig.shouldShowNavbar(location)) {
        debugPrint('👁️ Showing navbar for: $location');
        ref.read(navigationVisibilityProvider.notifier).show();
      } else {
        debugPrint('⚠️ Route not configured: $location - defaulting to show navbar');
        ref.read(navigationVisibilityProvider.notifier).show();
      }
    } catch (e) {
      debugPrint('❌ Error updating navbar visibility: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(networkStatusProvider);
    final themeType = ref.watch(appThemeProvider);
    final router = ref.watch(goRouterProvider);

    // 🔥 Update navbar whenever router changes
    ref.listen(goRouterProvider, (_, newRouter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateNavbarVisibility(ref, newRouter);
      });
    });

    return MaterialApp.router(
      routerConfig: router,
      theme: AppTheme.themByType(themeType),
      debugShowCheckedModeBanner: false,

      builder: (context, child) {
        return Stack(
          children: [
            child!,

            if (networkStatus == NetworkStatus.disconnected)
              const Positioned.fill(child: NoInternetScreen()),
          ],
        );
      },
    );
  }
}
