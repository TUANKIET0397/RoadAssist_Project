import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:road_assist/core/utils/geo_utils.dart';
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
      if (kDebugMode) {
        print('[RescueRepo] createRescueRequest: userId=$userId, vehicleType=$vehicleType');
      }
      
      String? imageUrl;
      if (image != null) {
        imageUrl = await uploadImage(userId, image);
      }
      
      final docData = {
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
        'progressStep': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('rescue_requests').add(docData);

      if (kDebugMode) {
        print('[RescueRepo] Created rescue request: ${docRef.id}');
      }
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('[RescueRepo] Lỗi create rescue request: $e');
      }
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

  /// Stream danh sách rescue requests của garage (accepted by garage)
  Stream<List<RescueRequestModel>> getGarageRequestsStream(String garageId) {
    return _firestore
        .collection('rescue_requests')
        .where('garageId', isEqualTo: garageId)
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
    final latDelta = GeoUtils.latDeltaForRadius(radiusKm);
    final lngDelta = GeoUtils.lngDeltaForRadius(radiusKm);

    final snapshot = await _firestore
        .collection('rescue_requests')
        .where('status', isEqualTo: 'pending')
        .where('latitude', isGreaterThan: latitude - latDelta)
        .where('latitude', isLessThan: latitude + latDelta)
        .get();

    return snapshot.docs
        .map((doc) => RescueRequestModel.fromMap(doc.id, doc.data()))
        .where((req) {
          return GeoUtils.isWithinRadius(
            centerLat: latitude,
            centerLng: longitude,
            pointLat: req.latitude,
            pointLng: req.longitude,
            radiusKm: radiusKm,
          ) && req.longitude >= longitude - lngDelta &&
              req.longitude <= longitude + lngDelta;
        })
        .toList();
  }

  // Đã chuyển sang GeoUtils.calculateDistance()


  /// Accept rescue request (dành cho garage)
  Future<bool> acceptRescueRequest({
    required String requestId,
    required String garageId,
    required String garageName,
    required String garagePhone,
  }) async {
    try {
      await _firestore.collection('rescue_requests').doc(requestId).update({
        'status': 'accepted',
        'progressStep': 1,
        'garageId': garageId,
        'name': garageName,
        'garagePhone': garagePhone,
        'acceptedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      if (kDebugMode) print('[RescueRepo] Lỗi accept rescue request: $e');
      return false;
    }
  }

  /// Lấy TẤT CẢ pending requests (không filter khoảng cách) - dùng cho testing
  Stream<List<RescueRequestModel>> getAllPendingRescueRequestsStream() {
    return _firestore
        .collection('rescue_requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return RescueRequestModel.fromMap(doc.id, doc.data());
            } catch (e) {
              if (kDebugMode) print('[RescueRepo] Lỗi parse doc ${doc.id}: $e');
              return null;
            }
          })
          .whereType<RescueRequestModel>()
          .toList();
    });
  }

  /// Cancel rescue request (chỉ update status, không xóa - dùng ở success screen sau khi garage đã chấp nhận)
  Future<bool> cancelRescueRequest(String requestId) async {
    try {
      await _firestore.collection('rescue_requests').doc(requestId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      if (kDebugMode) print('[RescueRepo] Lỗi cancel rescue request: $e');
      return false;
    }
  }

  /// Delete rescue request (xóa hoàn toàn từ database - dùng ở waiting screen)
  Future<bool> deleteRescueRequest(String requestId) async {
    try {
      await _firestore.collection('rescue_requests').doc(requestId).delete();
      return true;
    } catch (e) {
      if (kDebugMode) print('[RescueRepo] Lỗi delete rescue request: $e');
      return false;
    }
  }

  /// Set rescue request to timed_out
  Future<bool> setRescueRequestTimedOut(String requestId) async {
    try {
      await _firestore.collection('rescue_requests').doc(requestId).update({
        'status': 'timed_out',
      });
      return true;
    } catch (e) {
      if (kDebugMode) print('[RescueRepo] Lỗi set timed out: $e');
      return false;
    }
  }

  /// Stream một rescue request cụ thể
  Stream<RescueRequestModel?> getRescueRequestStream(String requestId) {
    return _firestore
        .collection('rescue_requests')
        .doc(requestId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return RescueRequestModel.fromMap(doc.id, doc.data()!);
          } else {
            return null;
          }
        });
  }

  /// Stream danh sách rescue requests pending của garage (gần vị trí) - LIMIT 50 để tránh lag
  Stream<List<RescueRequestModel>> getPendingRescueRequestsStream({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) {
    return _firestore
        .collection('rescue_requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      if (kDebugMode) {
        print('[RescueRepo] getPendingRescueRequestsStream: ${snapshot.docs.length} docs');
      }
      
      final requests = snapshot.docs
          .map((doc) {
            try {
              return RescueRequestModel.fromMap(doc.id, doc.data());
            } catch (e) {
              if (kDebugMode) {
                print('[RescueRepo] Lỗi parse doc ${doc.id}: $e');
              }
              return null;
            }
          })
          .whereType<RescueRequestModel>()
          .where((req) {
            return GeoUtils.isWithinRadius(
              centerLat: latitude,
              centerLng: longitude,
              pointLat: req.latitude,
              pointLng: req.longitude,
              radiusKm: radiusKm,
            );
          })
          .toList();
      
      if (kDebugMode) {
        print('[RescueRepo] Kết quả: ${requests.length} requests gần vị trí');
      }
      return requests;
    });
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

/// Stream rescue request cụ thể (dành cho user waiting)
final currentRescueRequestProvider = StreamProvider.family
    .autoDispose<RescueRequestModel?, String>((ref, requestId) {
      final repo = ref.watch(rescueRequestRepoProvider);
      return repo.getRescueRequestStream(requestId);
    });

/// Stream pending rescue requests gần vị trí (dành cho garage)
final pendingRescueRequestsProvider = StreamProvider.family.autoDispose<
    List<RescueRequestModel>,
    Map<String, double>>((ref, location) {
  final repo = ref.watch(rescueRequestRepoProvider);
  return repo.getPendingRescueRequestsStream(
    latitude: location['lat']!,
    longitude: location['lng']!,
    radiusKm: location['radius'] ?? 10.0,
  );
});

/// 🧪 TESTING: Provider lấy TẤT CẢ pending requests (không filter khoảng cách)
final allPendingRescueRequestsProvider = StreamProvider.autoDispose<
    List<RescueRequestModel>>((ref) {
  final repo = ref.watch(rescueRequestRepoProvider);
  return repo.getAllPendingRescueRequestsStream();
});
