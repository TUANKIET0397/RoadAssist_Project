import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/errors/no_internet_screen.dart';
import 'package:road_assist/core/network/network_service.dart';
import 'package:road_assist/core/network/network_status.dart';
import 'package:road_assist/core/routes/app_routes.dart';
import 'package:road_assist/core/theme/app_theme.dart';
import 'package:road_assist/core/theme/theme_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(networkStatusProvider);
    final themeType = ref.watch(appThemeProvider);
    final router = ref.watch(goRouterProvider);

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
