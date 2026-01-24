import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:road_assist/core/auth/auth_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
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
      : super(const AuthState(
    isLoggedIn: false,
    isInitialized: false,
  )) {
    _listenAuth();
  }

  void _listenAuth() {
    _sub = ref
        .read(firebaseAuthProvider)
        .authStateChanges()
        .listen((user) async {
      if (user == null) {
        state = const AuthState.unauthenticated();
      } else {
        await _detectRoleFromFirestore(user.uid);
      }
    });
  }

  Future<void> _detectRoleFromFirestore(String uid) async {
    try {
      final firestore = ref.read(firestoreProvider);

      final userDoc =
      await firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        state = AuthState(
          isLoggedIn: true,
          isInitialized: true,
          userId: uid,
          role: UserRole.customer,
        );
        return;
      }

      final garageDoc =
      await firestore.collection('garages').doc(uid).get();

      if (garageDoc.exists) {
        state = AuthState(
          isLoggedIn: true,
          isInitialized: true,
          userId: uid,
          role: UserRole.garage,
        );
        return;
      }
      throw Exception('Account not found in users or garages');
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}


