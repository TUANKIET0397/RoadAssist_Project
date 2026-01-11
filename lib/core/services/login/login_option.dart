import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser =
      await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null;
      }

      // Lấy accessToken & idToken
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Tạo credential cho Firebase
      final AuthCredential credential =
      GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập Firebase
      final UserCredential userCredential =
      await _firebaseAuth.signInWithCredential(credential);

      final User? user = userCredential.user;

      // Lưu user vào Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'fullName': user.displayName,
          'email': user.email,
          'phone': user.phoneNumber,
          'role': 'customer',
          'provider': 'google',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return user;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  /// Lấy user hiện tại
  User? get currentUser => _firebaseAuth.currentUser;

  /// Đăng xuất
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _firebaseAuth.signOut();
  }
}
