import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  String _phoneNumber = '';
  String _password = '';
  bool _isLoading = false;
  bool _obscurePassword = true;

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
    _isLoading = true;
    notifyListeners();

    // Implement actual login logic here
    await Future.delayed(Duration(seconds: 2));
    
    _isLoading = false;
    notifyListeners();
    
    return true; // Return success/failure
  }

  Future<void> loginWithGoogle() async {
    // Implement Google login
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