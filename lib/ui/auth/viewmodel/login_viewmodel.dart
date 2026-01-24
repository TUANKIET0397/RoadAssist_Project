import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/auth/auth_state.dart';
import 'package:road_assist/core/providers/selected_role.dart';
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

  Future<bool> login(WidgetRef ref) async {
    if (_phoneNumber.isEmpty || _password.isEmpty) {
      return false;
    }

    final selectedRole = ref.read(selectedRoleProvider);

    if (selectedRole == null) {
      debugPrint('No role selected');
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final String email;

      if (_phoneNumber.contains('@')) {
        email = _phoneNumber.trim();
      } else {
        email = selectedRole == UserRole.customer
            ? '${_phoneNumber.trim()}@roadassist.com'
            : '${_phoneNumber.trim()}@garage.roadassist.vn';
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: _password.trim(),
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

/// ✅ RIVERPOD PROVIDER (đặt chung file)
final loginViewModelProvider = ChangeNotifierProvider<LoginViewModel>((ref) {
  final vm = LoginViewModel();

  ref.onDispose(() {
    vm.dispose();
  });

  return vm;
});
