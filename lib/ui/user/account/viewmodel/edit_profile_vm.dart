import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';



final editProfileProvider = StateNotifierProvider<EditProfileVM, bool>((ref) {
  return EditProfileVM();
});

bool _isValidGmail(String email) {
  final gmailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
  return gmailRegex.hasMatch(email.trim());
}

class EditProfileVM extends StateNotifier<bool> {
  EditProfileVM() : super(false);

  // Edit Avatar
  Future<String?> uploadAvatar(File file) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('❌ uploadAvatar: user null');
      return null;
    }

    try {
      final ref = FirebaseStorage.instance
          .ref('users/${user.uid}/avatar.jpg');

      debugPrint('📤 Uploading avatar...');

      final task = await ref.putFile(file);

      final url = await task.ref.getDownloadURL();

      debugPrint('✅ Upload success: $url');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'avatarUrl': url});

      return url;
    } catch (e, st) {
      debugPrint('❌ uploadAvatar error: $e');
      debugPrintStack(stackTrace: st);
      return null;
    }
  }



  Future<String?> saveProfile({
    required String name,
    required String phone,
    required String email,
    required String address,
    required String birthDate,
    File? avatarFile,
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

    if (avatarFile != null) {
      final url = await uploadAvatar(avatarFile);
      if (url == null) {
        state = false;
        return 'Upload avatar thất bại';
      }
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
