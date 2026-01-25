import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final editProfileProvider = StateNotifierProvider<EditProfileVM, bool>((ref) {
  return EditProfileVM();
});

bool _isValidGmail(String email) {
  final gmailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
  return gmailRegex.hasMatch(email.trim());
}

class EditProfileVM extends StateNotifier<bool> {
  EditProfileVM() : super(false);

  Future<String?> saveProfile({
    required String name,
    required String phone,
    required String email,
    required String address,
    required String birthDate,
  }) async {
    // ✅ VALIDATE BẮT BUỘC
    if (name.trim().isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }

    if (phone.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }

    if (email.isNotEmpty && !_isValidGmail(email)) {
      return 'Email phải là Gmail hợp lệ (__@gmail.com)';
    }

    state = true;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      state = false;
      return 'Người dùng chưa đăng nhập';
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': name.trim(),
      'phone': phone.trim(),
      'email': email.trim().isEmpty ? null : email.trim(),
      'address': address.trim(),
      'birthDate': birthDate.trim(),
    });

    state = false;
    return null;
  }
}
