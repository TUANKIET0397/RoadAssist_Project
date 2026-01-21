import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/errors/no_internet_screen.dart';
import 'package:road_assist/core/network/network_service.dart';
import 'package:road_assist/core/network/network_status.dart';
import 'package:road_assist/core/providers/auth_provider.dart';
import 'package:road_assist/splash_screen.dart';
import 'package:road_assist/ui/auth/view/login_screen.dart';
import 'package:road_assist/ui/navigation/view/main_screen.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeType = ref.watch(appThemeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themByType(themeType),
      home: const SplashWrapper(),
    );
  }
}

///
class SplashWrapper extends ConsumerStatefulWidget {
  const SplashWrapper({super.key});

  @override
  ConsumerState<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends ConsumerState<SplashWrapper> {
  bool _animationDone = false;

  @override
  Widget build(BuildContext context) {
    if (!_animationDone) {
      return SplashScreen(
        onAnimationComplete: () {
          setState(() {
            _animationDone = true;
          });
        },
      );
    }

    final networkStatus = ref.watch(networkStatusProvider);
    final authState = ref.watch(authStateProvider);

    /// 1️⃣ NO INTERNET
    if (networkStatus == NetworkStatus.disconnected) {
      return const NoInternetScreen();
    }

    /// 2️⃣ AUTH FLOW
    return authState.when(
      loading: () => const SizedBox(),
      error: (_, __) => const LoginScreen(),
      data: (User? user) {
        return user == null ? const LoginScreen() : const MainScreen();
      },
    );
  }
}
