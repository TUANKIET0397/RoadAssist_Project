import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:road_assist/core/services/gps/location_geolocator.dart';

final garageRegisterVMProvider =
    ChangeNotifierProvider<GarageRegisterScreenModel>(
      (ref) => GarageRegisterScreenModel(),
    );

/// VIEW MODEL
class GarageRegisterScreenModel extends ChangeNotifier {
  // Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  String? errorMessage;

  final nameController = TextEditingController();
  final taxCodeController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isAgree = false;

  double? latitude;
  double? longitude;

  final Set<int> selectedDays = {};
  TimeOfDay openTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay closeTime = const TimeOfDay(hour: 18, minute: 0);

  final List<String> allServices = [
    'Hết xăng',
    'Bể lốp',
    'Mất chìa khóa',
    'Hư máy',
    'Vận chuyển xe',
    'Xẹp lốp',
    'Không rõ nguyên nhân',
  ];
  final Set<String> selectedServices = {};

  final List<String> allVehicleTypes = [
    'Xe Số',
    'Xe Tay ga',
    'Xe Điện',
    'Ô tô',
    'Xe Bus',
    'Xe Container',
    'Xe Tải',
    'Xe Ba Gác',
  ];
  final List<String> selectedVehicleTypes = [];

  void toggleDay(int day) {
    selectedDays.contains(day)
        ? selectedDays.remove(day)
        : selectedDays.add(day);
    notifyListeners();
  }

  void setOpenTime(TimeOfDay time) {
    openTime = time;
    notifyListeners();
  }

  void setCloseTime(TimeOfDay time) {
    closeTime = time;
    notifyListeners();
  }

  void toggleService(String service) {
    selectedServices.contains(service)
        ? selectedServices.remove(service)
        : selectedServices.add(service);
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

  void toggleAgree(bool value) {
    isAgree = value;
    notifyListeners();
  }

  // MAP PICKER → GPS → ADDRESS
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

  // VALIDATION
  bool _validate() {
    if (nameController.text.trim().isEmpty) {
      errorMessage = 'Vui lòng nhập tên Garage';
      return false;
    }

    if (latitude == null || longitude == null) {
      errorMessage = 'Vui lòng chọn vị trí Garage trên bản đồ';
      return false;
    }

    if (!_isValidPhone(phoneController.text.trim())) {
      errorMessage = 'Số điện thoại không hợp lệ';
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

    if (selectedDays.isEmpty) {
      errorMessage = 'Chưa chọn ngày hoạt động';
      return false;
    }

    if (openTime == null || closeTime == null) {
      errorMessage = 'Chưa chọn giờ hoạt động';
      return false;
    }

    if (selectedServices.isEmpty) {
      errorMessage = 'Chưa chọn dịch vụ';
      return false;
    }

    if (selectedVehicleTypes.isEmpty) {
      errorMessage = 'Chưa chọn loại phương tiện';
      return false;
    }

    errorMessage = null;
    return true;
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^0\d{9,10}$').hasMatch(phone);
  }

  // register garage to firebase
  Future<bool> registerGarage() async {
    if (!_validate()) {
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final email = '${phoneController.text.trim()}@garage.roadassist.vn';

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;

      await _firestore.collection('garages').doc(uid).set({
        'id': uid,
        'role': 'garage',
        'name': nameController.text.trim(),
        'taxCode': taxCodeController.text.trim(),
        'address': addressController.text.trim(),
        'phone': phoneController.text.trim(),
        'location': {'lat': latitude, 'lng': longitude},
        'operatingDays': selectedDays.toList(),
        'openTime':
            '${openTime.hour.toString().padLeft(2, '0')}:${openTime.minute.toString().padLeft(2, '0')}',
        'closeTime':
            '${closeTime.hour.toString().padLeft(2, '0')}:${closeTime.minute.toString().padLeft(2, '0')}',
        'issues': selectedServices.toList(),
        'vehicleTypes': selectedVehicleTypes,
        'image': "",
        'bgimage': "",
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Số điện thoại đã được đăng ký';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Mật khẩu quá yếu';
      } else {
        errorMessage = e.message;
      }
      return false;
    } catch (e) {
      errorMessage = 'Đăng ký garage thất bại';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // DISPOSE
  @override
  void dispose() {
    nameController.dispose();
    taxCodeController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
