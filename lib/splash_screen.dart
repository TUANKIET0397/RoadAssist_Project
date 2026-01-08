import 'package:flutter/material.dart';
import 'package:road_assist/presentation/views/auth/login_screen.dart';
import 'package:road_assist/presentation/views/auth/splash_screen.dart';

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
