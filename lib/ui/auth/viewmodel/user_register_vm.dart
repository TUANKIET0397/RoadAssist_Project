import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:road_assist/core/services/gps/location_geolocator.dart';

final userRegisterVMProvider = ChangeNotifierProvider<UserRegisterViewModel>(
  (ref) => UserRegisterViewModel(),
);

/// USER REGISTER VIEW MODEL
class UserRegisterViewModel extends ChangeNotifier {
  // Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  double? latitude;
  double? longitude;

  // Loading & Error State
  bool isLoading = false;
  String? errorMessage;

  // Controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Agreement
  bool isAgree = false;

  // Vehicle Types
  final List<String> allVehicleTypes = [
    'Xe Bốn bánh',
    'Xe máy',
    'Ô tô',
    'Xe tải',
  ];
  final List<String> selectedVehicleTypes = [];

  // Thêm loại đầu tiên làm mặc định
  // UserRegisterViewModel() {
  //   if (selectedVehicleTypes.isEmpty) {
  //     selectedVehicleTypes.add(allVehicleTypes.first);
  //   }
  // }

  void toggleAgree(bool value) {
    isAgree = value;
    notifyListeners();
  }

  void addVehicleType() {
    final available = allVehicleTypes
        .where((e) => !selectedVehicleTypes.contains(e))
        .toList();

    if (available.isNotEmpty) {
      selectedVehicleTypes.add(available.first);
      notifyListeners();
    }
  }

  void removeVehicleType(int index) {
    if (index >= 0 && index < selectedVehicleTypes.length) {
      selectedVehicleTypes.removeAt(index);
      notifyListeners();
    }
  }

  void updateVehicleType(int index, String newType) {
    if (index >= 0 &&
        index < selectedVehicleTypes.length &&
        !selectedVehicleTypes.contains(newType)) {
      selectedVehicleTypes[index] = newType;
      notifyListeners();
    }
  }

  Future<void> setLocationFromLatLng({
    required double lat,
    required double lng,
  }) async {
    latitude = lat;
    longitude = lng;

    try {
      final addr = await LocationService.getAddressFromLatLng(lat, lng);
      addressController.text = addr;
    } catch (e) {
      addressController.text = '$lat, $lng';
    }

    notifyListeners();
  }

  // Validation
  bool _validate() {
    // Name validation
    if (nameController.text.trim().isEmpty) {
      errorMessage = 'Vui lòng nhập họ và tên';
      return false;
    }

    // Email validation (optional but must be valid if provided)
    if (emailController.text.trim().isNotEmpty &&
        !_isValidEmail(emailController.text.trim())) {
      errorMessage = 'Email không hợp lệ';
      return false;
    }

    // Password validation
    if (passwordController.text.isEmpty) {
      errorMessage = 'Vui lòng nhập mật khẩu';
      return false;
    }

    if (passwordController.text.length < 6) {
      errorMessage = 'Mật khẩu phải có ít nhất 6 ký tự';
      return false;
    }

    // Confirm password validation
    if (passwordController.text != confirmPasswordController.text) {
      errorMessage = 'Mật khẩu xác nhận không khớp';
      return false;
    }

    // Vehicle types validation
    if (selectedVehicleTypes.isEmpty) {
      errorMessage = 'Vui lòng chọn ít nhất một loại phương tiện';
      return false;
    }

    // Agreement validation
    if (!isAgree) {
      errorMessage = 'Vui lòng đồng ý với điều khoản sử dụng';
      return false;
    }

    errorMessage = null;
    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Register User
  Future<bool> registerUser() async {
    if (!_validate()) {
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Create user with Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailController.text.trim().isEmpty
                ? '${phoneController.text.trim()}@roadassist.com'
                : emailController.text.trim(),
            password: passwordController.text,
          );

      final userId = userCredential.user!.uid;

      // Save user data to Firestore
      await _firestore.collection('users').doc(userId).set({
        'id': userId,
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'email': emailController.text.trim(),
        // 'vehicles': selectedVehicleTypes,
        'vehicles': selectedVehicleTypes
            .map((type) => {'type': type, 'description': null})
            .toList(),
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'customer',
      });

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        errorMessage = 'Mật khẩu quá yếu';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Số điện thoại đã được sử dụng';
      } else {
        errorMessage = 'Đăng ký thất bại: ${e.message}';
      }
      return false;
    } catch (e) {
      errorMessage = 'Đăng ký thất bại. Vui lòng thử lại';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Dispose
  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
