import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/app.dart';

// //firebase
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

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

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(
//           create: (_) => GarageViewModel(),
//         ),
//       ],
//       child: MaterialApp(
//         title: 'RoadAssist',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           textTheme: GoogleFonts.poppinsTextTheme(),
//           primaryColor: const Color(0xFF242C3B),
//           brightness: Brightness.dark,
//         ),
//         home: const SplashWrapper(),
//       ),
//     );
//   }
// }
