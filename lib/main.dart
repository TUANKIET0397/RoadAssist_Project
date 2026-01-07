import 'package:flutter/material.dart';
//import 'package:road_assist/presentation/views/auth/login_screen.dart';
//import 'package:road_assist/presentation/views/auth/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:road_assist/presentation/viewmodels/auth/login_viewmodel.dart';

//import 'package:road_assist/presentation/views/home/home_page.dart';
import 'package:road_assist/presentation/views/garage/garageDetail.dart';
import 'package:road_assist/presentation/views/garage/garageList_screen.dart';

import 'package:road_assist/presentation/views/garage/chatList_screen.dart';

//firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

//void main() => runApp(const HomePage());


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(),
        ),
        // Thêm những viewmodel dùng chung nhiều màn hình
      ],
      child: MaterialApp(
        title: 'RoadAssist',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(),
          primaryColor: const Color(0xFF242C3B),
          brightness: Brightness.dark,
        ),
        home: const ChatGarageScreen(),
      ),
    );
  }
}
//
// class SplashWrapper extends StatefulWidget {
//   const SplashWrapper({super.key});
//
//   @override
//   State<SplashWrapper> createState() => _SplashWrapperState();
// }
//
// class _SplashWrapperState extends State<SplashWrapper> {
//   bool _showLogin = false;
//
//   @override
//   Widget build(BuildContext context) {
//     if (_showLogin) {
//       return LoginScreen();
//     }
//
//     return SplashScreen(
//       onAnimationComplete: () {
//         setState(() {
//           _showLogin = true;
//         });
//       },
//     );
//   }
// }