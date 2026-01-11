import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';

/// Repository
class RescueRequestRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload ảnh lên Firebase Storage
  Future<String?> uploadImage(String userId, File image) async {
    try {
      final fileName = 'rescue_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('rescue_requests/$userId/$fileName');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Lỗi upload image: $e');
      return null;
    }
  }

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
      String? imageUrl;
      if (image != null) {
        imageUrl = await uploadImage(userId, image);
      }

      // Add lên firebase
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

      return docRef.id;
    } catch (e) {
      print('Lỗi create rescue request: $e');
      return null;
    }
  }

  /// Stream danh sách rescue requests của user
  Stream<List<RescueRequestModel>> getUserRequestsStream(String userId) {
    return _firestore
        .collection('rescue_requests')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RescueRequestModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Load rescue requests gần vị trí (dành cho garage)
  Future<List<RescueRequestModel>> loadNearbyRequests({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    final latDelta = radiusKm / 111.0;
    final lngDelta = radiusKm / (111.0 * 0.7); // approximation

    final snapshot = await _firestore
        .collection('rescue_requests')
        .where('status', isEqualTo: 'pending')
        .where('latitude', isGreaterThan: latitude - latDelta)
        .where('latitude', isLessThan: latitude + latDelta)
        .get();

    return snapshot.docs
        .map((doc) => RescueRequestModel.fromMap(doc.id, doc.data()))
        .where((req) {
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
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295;
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2*R, R = 6371 km
  }
}

/// Riverpod Providers
final rescueRequestRepoProvider = Provider<RescueRequestRepository>((ref) {
  return RescueRequestRepository();
});

final userRescueRequestsProvider = StreamProvider.family
    .autoDispose<List<RescueRequestModel>, String>((ref, userId) {
      final repo = ref.watch(rescueRequestRepoProvider);
      return repo.getUserRequestsStream(userId);
    });

final rescueNearbyProvider = FutureProvider.family
    .autoDispose<List<RescueRequestModel>, Map<String, double>>((ref, loc) {
      final repo = ref.watch(rescueRequestRepoProvider);
      return repo.loadNearbyRequests(
        latitude: loc['lat']!,
        longitude: loc['lng']!,
        radiusKm: loc['radius'] ?? 10.0,
      );
    });
