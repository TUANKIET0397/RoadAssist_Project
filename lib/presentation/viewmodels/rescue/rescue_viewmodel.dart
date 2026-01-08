import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:road_assist/data/models/response/rescue_request_model.dart';


class RescueViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isLoading = false;
  List<RescueRequestModel> _requests = [];

  bool get isLoading => _isLoading;
  List<RescueRequestModel> get requests => _requests;

  /// Tạo rescue request mới
  Future<String?> createRescueRequest({
    required String userId,
    required String userName,
    required String userPhone,
    required String vehicleType,
    required String vehicleModel,
    required List<String> issues,
    required String location,
    required double latitude,
    required double longitude,
    File? image,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      String? imageUrl;

      // Upload image nếu có
      if (image != null) {
        imageUrl = await _uploadImage(userId, image);
      }

      // Tạo rescue request
      final docRef = await _firestore.collection('rescue_requests').add({
        'userId': userId,
        'userName': userName,
        'userPhone': userPhone,
        'vehicleType': vehicleType,
        'vehicleModel': vehicleModel,
        'issues': issues,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'imageUrl': imageUrl,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Tạo rescue request thành công: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Lỗi create rescue request: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Upload image lên Firebase Storage
  Future<String?> _uploadImage(String userId, File image) async {
    try {
      final fileName = 'rescue_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('rescue_requests/$userId/$fileName');

      await ref.putFile(image);
      final url = await ref.getDownloadURL();

      return url;
    } catch (e) {
      debugPrint('❌ Lỗi upload image: $e');
      return null;
    }
  }

  /// Load danh sách rescue requests của user
  Stream<List<RescueRequestModel>> getUserRequestsStream(String userId) {
    return _firestore
        .collection('rescue_requests')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RescueRequestModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// Load danh sách rescue requests gần vị trí (cho garage)
  Future<void> loadNearbyRequests({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Tính toán bounds (đơn giản - có thể cải thiện với geohash)
      final latDelta = radiusKm / 111.0;
      final lngDelta = radiusKm / (111.0 * 0.7); // cos(latitude) approximation

      final snapshot = await _firestore
          .collection('rescue_requests')
          .where('status', isEqualTo: 'pending')
          .where('latitude', isGreaterThan: latitude - latDelta)
          .where('latitude', isLessThan: latitude + latDelta)
          .get();

      _requests = snapshot.docs
          .map((doc) => RescueRequestModel.fromMap(doc.id, doc.data()))
          .where((req) {
        // Filter by longitude and actual distance
        final distance = _calculateDistance(
          latitude,
          longitude,
          req.latitude,
          req.longitude,
        );
        return req.longitude >= longitude - lngDelta &&
            req.longitude <= longitude + lngDelta &&
            distance <= radiusKm;
      })
          .toList();
    } catch (e) {
      debugPrint('❌ Lỗi load nearby requests: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Garage accept rescue request
  Future<bool> acceptRescueRequest({
    required String requestId,
    required String garageId,
    required String garageName,
  }) async {
    try {
      await _firestore.collection('rescue_requests').doc(requestId).update({
        'status': 'accepted',
        'garageId': garageId,
        'garageName': garageName,
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Garage đã nhận yêu cầu');
      return true;
    } catch (e) {
      debugPrint('❌ Lỗi accept request: $e');
      return false;
    }
  }

  /// Complete rescue request
  Future<bool> completeRescueRequest(String requestId) async {
    try {
      await _firestore.collection('rescue_requests').doc(requestId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Hoàn thành rescue request');
      return true;
    } catch (e) {
      debugPrint('❌ Lỗi complete request: $e');
      return false;
    }
  }

  /// Cancel rescue request
  Future<bool> cancelRescueRequest(String requestId) async {
    try {
      await _firestore.collection('rescue_requests').doc(requestId).update({
        'status': 'cancelled',
      });

      debugPrint('✅ Đã hủy rescue request');
      return true;
    } catch (e) {
      debugPrint('❌ Lỗi cancel request: $e');
      return false;
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}
