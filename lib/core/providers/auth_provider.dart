import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:road_assist/core/auth/auth_state.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

final userIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).userId;
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  StreamSubscription<User?>? _sub;

  AuthNotifier(this.ref)
    : super(const AuthState(isLoggedIn: false, isInitialized: false)) {
    _listenAuth();
  }

  void _listenAuth() {
    _sub = ref.read(firebaseAuthProvider).authStateChanges().listen((user) {
      if (user == null) {
        state = const AuthState(isLoggedIn: false, isInitialized: true);
      } else {
        state = AuthState(
          isLoggedIn: true,
          isInitialized: true,
          userId: user.uid,
          role: UserRole.customer, // TODO lấy từ backend
        );
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
