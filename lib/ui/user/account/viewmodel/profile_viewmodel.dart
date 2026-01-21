import 'package:flutter/material.dart';
import 'package:road_assist/data/models/user.dart';

class ProfileViewModel extends ChangeNotifier {
  late User _profile;

  // Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final birthDateController = TextEditingController();

  User get profile => _profile;

  ProfileViewModel() {
    _loadProfile();
  }

  void _loadProfile() {
    // Fake data (sau này thay bằng API / Database)
    _profile = User(
      firstName: 'Nguyễn Minh',
      lastName: 'Thuận',
      phone: '+84 337 760 280',
      email: 'minhthuan2604@gmail.com',
      address: '15B Đ. Nguyễn Lương Bằng, Quận 7',
      birthDate: DateTime(2005, 4, 26),
      isVerified: true,
      password: 'examplePassword123',
    );

    _bindDataToController();
  }

  void _bindDataToController() {
    firstNameController.text = _profile.firstName;
    lastNameController.text = _profile.lastName;
    phoneController.text = _profile.phone;
    emailController.text = _profile.email;
    addressController.text = _profile.address;
    birthDateController.text =
        '${_profile.birthDate.day}/${_profile.birthDate.month}/${_profile.birthDate.year}';
  }

  void saveProfile() {
    _profile = User(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      phone: phoneController.text,
      email: emailController.text,
      address: addressController.text,
      birthDate: _profile.birthDate,
      isVerified: _profile.isVerified,
      password: 'examplePassword123',
    );

    notifyListeners();
    debugPrint('Profile saved: ${_profile.firstName} ${_profile.lastName}');
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    birthDateController.dispose();
    super.dispose();
  }
}
