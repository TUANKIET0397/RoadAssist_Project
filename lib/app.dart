import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/providers/auth_provider.dart';
import 'package:road_assist/presentation/views/auth/login_screen.dart';
import 'package:road_assist/presentation/views/navigation/view/main_screen.dart';
import 'package:road_assist/splash_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final themeType = ref.watch(appThemeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.byType(themeType),
      // home: authState.when(
      //   loading: () => const SplashWrapper(),
      //   error: (_, __) => const LoginScreen(),
      //   data: (user) {
      //     if (user == null) {
      //       // return const LoginScreen(); // 👉 feature auth
      //       return Text('success');
      //     }
      //     return const MainScreen(); // 👉 navigation shell
      //   },
      // ),
      home: authState == null ? const LoginScreen() : const MainScreen(),
    );
  }
}
