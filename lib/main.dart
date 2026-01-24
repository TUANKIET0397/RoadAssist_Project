import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/app.dart';

// //firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // 🧪 TESTING: Tắt Firestore cache để load từ server (không dùng cache cũ)
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false, // ← Tắt offline persistence
  );

  runApp(const ProviderScope(child: MyApp()));
}
