import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/user/garage/viewmodel/garageDetail_viewmodel.dart';

class ReviewSubmitHandler {
  static Future<void> submit({
    required BuildContext context,
    required WidgetRef ref,
    required String garageId,
    required int rating,
    required TextEditingController controller,
    VoidCallback? onDone,
  }) async {
    final authUser = FirebaseAuth.instance.currentUser;

    if (authUser == null) {
      _toast(context, 'Bạn cần đăng nhập để đánh giá');
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(authUser.uid)
        .get();

    if (!userDoc.exists) {
      _toast(context, 'Không tìm thấy thông tin người dùng');
      return;
    }

    final userData = userDoc.data()!;

    await ref.read(garageDetailProvider.notifier).submitReview(
      garageId: garageId,
      userId: authUser.uid,
      userName: userData['name'] ?? 'Ẩn danh',
      userAvatar: userData['avatar'],
      rating: rating,
      comment: controller.text.trim(),
    );

    controller.clear();
    onDone?.call();
    Navigator.of(context).pop();
  }

  static void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
