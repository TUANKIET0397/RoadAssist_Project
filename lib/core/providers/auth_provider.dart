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
<<<<<<< HEAD
  return 'mock-user-id kk'; // hoặc null để test login
=======
  return 'JPAIBTQhXVYuW9obsQukIAWWsi03'; // hoặc null để test login
>>>>>>> 0c090f0001d9b6aa41c7043f70947c8dc6aaa7c4
});

/// Nếu em có userIdProvider riêng
final userIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider);
});
