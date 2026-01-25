import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:road_assist/data/models/user_model.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final accountStreamProvider = StreamProvider<UserModel?>((ref) {
  final authAsync = ref.watch(authStateProvider);

  return authAsync.when(
    // loading / error → không emit user
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
    data: (authUser) {
      // 🔴 Chưa đăng nhập
      if (authUser == null) {
        return const Stream.empty();
      }

      // 🔵 Đã đăng nhập → listen đúng UID hiện tại
      return FirebaseFirestore.instance
          .collection('users')
          .doc(authUser.uid)
          .snapshots()
          .map((doc) {
            if (!doc.exists) return null;

            final data = doc.data();
            if (data == null) return null;

            return UserModel.fromJson(data);
          });
    },
  );
});
