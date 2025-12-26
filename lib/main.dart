import 'package:flutter/material.dart';
import 'package:road_assist/views/login_screen.dart';
import 'package:road_assist/views/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoadAssist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        primaryColor: const Color(0xFF242C3B),
        brightness: Brightness.dark,
      ),
      home: SplashWrapper(),
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