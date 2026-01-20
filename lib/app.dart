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
    final authState = ref.watch(authStateProvider);
    final themeType = ref.watch(appThemeProvider);
    final networkStatus = ref.watch(networkStatusProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themByType(themeType),

      home: _buildHome(networkStatus: networkStatus, authState: authState),
    );
  }

  //
  Widget _buildHome({
    required NetworkStatus networkStatus,
    required AsyncValue<User?> authState,
  }) {
    /// 1️⃣ NO INTERNET – override toàn app
    if (networkStatus == NetworkStatus.disconnected) {
      return const NoInternetScreen();
    }

    /// 2️⃣ AUTH FLOW
    return authState.when(
      loading: () => const SplashWrapper(),
      error: (_, __) => const LoginScreen(),
      data: (user) {
        return user == null ? const LoginScreen() : const MainScreen();
      },
    );
  }
}

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _showLogin = false;

  @override
  Widget build(BuildContext context) {
    if (_showLogin) {
      return LoginScreen();
    }

    return SplashScreen(
      onAnimationComplete: () {
        setState(() {
          _showLogin = true;
        });
      },
    );
  }
}
