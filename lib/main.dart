import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/app.dart';

// import 'package:road_assist/presentation/views/chat/chat_screen.dart';
// import 'package:road_assist/presentation/viewmodels/chat/chat_viewmodel.dart';
// import 'package:provider/provider.dart';

// //firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MaterialApp(
        home: MyApp(),
      ),
    ),
  );
}

// void main() {
//   runApp(
//     MultiProvider(
//       providers: [
//         // Khai báo Provider cho ChatViewModel ở đây
//         ChangeNotifierProvider(create: (_) => ChatViewModel()),
//       ],
//       child: const MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: ChatScreen(),
//       ),
//     ),
//   );
// }
