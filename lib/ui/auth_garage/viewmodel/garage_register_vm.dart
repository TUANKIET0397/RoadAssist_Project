import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:road_assist/core/services/gps/location_geolocator.dart';

final garageRegisterVMProvider =
ChangeNotifierProvider<GarageRegisterViewModel>(
        (ref) => GarageRegisterViewModel());

/// VIEW MODEL
class GarageRegisterViewModel extends ChangeNotifier {

  // Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool isLoading = false;
  String? errorMessage;

  final nameController = TextEditingController();
  final taxCodeController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  bool  isAgree = false;


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
    'Xe Bốn bánh',
    'Xe máy',
    'Ô tô',
    'Xe tải',
  ];
  final List<String> selectedVehicleTypes = [];

  final List<File> selectedImages = [];

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
      final addr =
      await LocationService.getAddressFromLatLng(lat, lng);
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
      final docRef = _firestore.collection('garages').doc();
      final garageId = docRef.id;


      await docRef.set({
        'id': garageId,
        'name': nameController.text.trim(),
        'taxCode': taxCodeController.text.trim(),
        'address': addressController.text.trim(),
        'phone': phoneController.text.trim(),
        'location': {
          'lat': latitude,
          'lng': longitude,
        },
        'operatingDays': selectedDays.toList(),
        'openTime':
        '${openTime!.hour.toString().padLeft(2, '0')}:${openTime!.minute.toString().padLeft(2, '0')}',
        'closeTime':
        '${closeTime!.hour.toString().padLeft(2, '0')}:${closeTime!.minute.toString().padLeft(2, '0')}',
        'services': selectedServices.toList(),
        'vehicleTypes': selectedVehicleTypes,
        'images': "",
        'bgImages': "",
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      errorMessage = 'Đăng ký thất bại';
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
