import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:road_assist/core/services/login/login_option.dart';

class LoginViewModel extends ChangeNotifier {
  String _phoneNumber = '';
  String _password = '';
  bool _isLoading = false;
  bool _obscurePassword = true;
  final AuthService _authService = AuthService();

  String get phoneNumber => _phoneNumber;
  String get password => _password;
  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;

  void setPhoneNumber(String value) {
    _phoneNumber = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<bool> login() async {
    if (_phoneNumber.isEmpty || _password.isEmpty) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Convert phone → email
      final email = _phoneNumber.contains('@')
          ? _phoneNumber
          : '${_phoneNumber.trim()}@roadassist.com';

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: _password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();

      debugPrint('Login error: ${e.code}');
      return false;
    }
  }


  Future<User?> loginWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = await _authService.signInWithGoogle();

      _isLoading = false;
      notifyListeners();

      return user;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Google login error: $e');
      return null;
    }
  }

  Future<void> loginWithApple() async {
    // mplement Apple login
  }

  Future<void> loginWithFacebook() async {
    //  Implement Facebook login
  }

  Future<void> loginWithFaceId() async {
    // Implement Face ID login
  }
}
