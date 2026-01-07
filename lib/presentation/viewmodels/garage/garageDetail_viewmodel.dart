import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GarageDetailViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  List<Map<String, dynamic>> _reviews = [];

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get reviews => _reviews;

  /// Load chi tiết garage và reviews
  Future<void> loadGarageDetails(String garageId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load reviews từ Firestore
      final reviewSnapshot = await _firestore
          .collection('garages')
          .doc(garageId)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .limit(10) // Giới hạn 10 reviews mới nhất
          .get();

      _reviews = reviewSnapshot.docs.map((doc) {
        final data = doc.data();
        final timestamp = data['createdAt'] as Timestamp?;

        // Tính toán thời gian đã qua
        String timeAgo = _getTimeAgo(timestamp);

        return {
          'id': doc.id,
          'userName': data['userName'] ?? 'Ẩn danh',
          'rating': data['rating'] ?? 0,
          'comment': data['comment'] ?? '',
          'time': timeAgo,
          'createdAt': timestamp,
        };
      }).toList();
    } catch (e) {
      debugPrint('Lỗi load garage details: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Submit review mới
  Future<void> submitReview({
    required String garageId,
    required String userId,
    required String userName,
    required int rating,
    required String comment,
  }) async {
    try {
      // Thêm review vào collection
      await _firestore
          .collection('garages')
          .doc(garageId)
          .collection('reviews')
          .add({
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Cập nhật rating trung bình của garage
      await _updateGarageRating(garageId);

      // Reload reviews
      await loadGarageDetails(garageId);

      debugPrint('Đánh giá đã được gửi');
    } catch (e) {
      debugPrint('Lỗi submit review: $e');
    }
  }

  /// Cập nhật rating trung bình của garage
  Future<void> _updateGarageRating(String garageId) async {
    try {
      final reviewSnapshot = await _firestore
          .collection('garages')
          .doc(garageId)
          .collection('reviews')
          .get();

      if (reviewSnapshot.docs.isEmpty) return;

      // Tính rating trung bình
      double totalRating = 0;
      for (var doc in reviewSnapshot.docs) {
        totalRating += (doc.data()['rating'] ?? 0).toDouble();
      }
      double avgRating = totalRating / reviewSnapshot.docs.length;

      // Cập nhật vào document garage
      await _firestore.collection('garages').doc(garageId).update({
        'rating': avgRating,
        'totalReviews': reviewSnapshot.docs.length,
      });
    } catch (e) {
      debugPrint('Lỗi update rating: $e');
    }
  }

  /// Tính thời gian đã qua (time ago)
  String _getTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Vừa xong';

    final now = DateTime.now();
    final reviewTime = timestamp.toDate();
    final difference = now.difference(reviewTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} năm trước';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  /// Delete review
  Future<void> deleteReview({
    required String garageId,
    required String reviewId,
  }) async {
    try {
      await _firestore
          .collection('garages')
          .doc(garageId)
          .collection('reviews')
          .doc(reviewId)
          .delete();

      await _updateGarageRating(garageId);

      // Reload reviews
      await loadGarageDetails(garageId);

      debugPrint('✅ Đã xóa đánh giá');
    } catch (e) {
      debugPrint('❌ Lỗi delete review: $e');
    }
  }
}