import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/app.dart';
// import 'package:road_assist/presentation/views/auth/login_screen.dart';
// import 'package:road_assist/presentation/views/auth/splash_screen.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:road_assist/presentation/viewmodels/garage/garageList_viewmodel.dart';
// import 'package:road_assist/presentation/views/home/home_page.dart';

// //firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// void main() => runApp(const HomePage());
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// class SplashWrapper extends StatefulWidget {
//   const SplashWrapper({super.key});

//   @override
//   State<SplashWrapper> createState() => _SplashWrapperState();
// }

// class _SplashWrapperState extends State<SplashWrapper> {
//   bool _showLogin = false;

//   @override
//   Widget build(BuildContext context) {
//     if (_showLogin) {
//       return LoginScreen();
//     }

//     return SplashScreen(
//       onAnimationComplete: () {
//         setState(() {
//           _showLogin = true;
//         });
//       },
//     );
//   }
// }