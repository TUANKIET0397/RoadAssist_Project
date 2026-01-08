import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// final authStateProvider = StreamProvider<User?>((ref) {
//   return ref.watch(firebaseAuthProvider).authStateChanges();
// });

// final userIdProvider = Provider<String?>((ref) {
//   final user = ref.watch(authStateProvider).value;
//   return user?.uid;
// });

/// Giả lập user đã đăng nhập
final authStateProvider = Provider<String?>((ref) {
  return 'mock-user-id'; // hoặc null để test login
});

/// Nếu em có userIdProvider riêng
final userIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider);
});
