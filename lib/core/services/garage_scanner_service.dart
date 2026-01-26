import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/garage_model.dart';

enum ScanPhase {
  phase1, // 5km trong 1 phút
  phase2, // 10km trong 1 phút  
  completed,
  failed,
}

class ScanResult {
  final ScanPhase phase;
  final List<GarageModel> garages;
  final bool hasAcceptance;
  final String? acceptedGarageId;
  final String? acceptedGarageName;

  ScanResult({
    required this.phase,
    required this.garages,
    this.hasAcceptance = false,
    this.acceptedGarageId,
    this.acceptedGarageName,
  });
}

// Provider cho GarageScannerService
final garageScannerServiceProvider = Provider<GarageScannerService>((ref) {
  return GarageScannerService();
});

class GarageScannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _phaseTimer;
  Timer? _cleanupTimer;
  StreamController<ScanResult>? _resultController;
  StreamSubscription? _acceptanceSubscription;

  GarageScannerService() {
    _startCleanupTimer();
  }

  /// Bắt đầu timer để cleanup notifications expired
  void _startCleanupTimer() {
    // Chạy cleanup task mỗi 5 phút
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      cleanupExpiredNotifications();
    });
  }



  /// Bắt đầu quét garage theo 2 đợt
  Stream<ScanResult> scanForGarages({
    required String rescueRequestId,
    required double userLat,
    required double userLng,
  }) {
    _resultController = StreamController<ScanResult>.broadcast();
    
    _startPhase1Scan(
      rescueRequestId: rescueRequestId,
      userLat: userLat,
      userLng: userLng,
    );

    return _resultController!.stream;
  }

  /// Đợt 1: Quét trong bán kính 5km
  Future<void> _startPhase1Scan({
    required String rescueRequestId,
    required double userLat,
    required double userLng,
  }) async {
    debugPrint('🔍 === PHASE 1 START ===');
    debugPrint('🔍 Bắt đầu đợt 1: Quét garage trong bán kính 5km');
    debugPrint('📍 User: lat=$userLat, lng=$userLng');
    debugPrint('🆔 Rescue Request ID: $rescueRequestId');

    try {
      // Tìm garage trong bán kính 5km
      final nearbyGarages = await _findNearbyGarages(
        userLat: userLat,
        userLng: userLng,
        radiusKm: 5.0,
      );

      debugPrint('🏪 Đợt 1: Tìm thấy ${nearbyGarages.length} garage trong 5km');

      if (nearbyGarages.isEmpty) {
        debugPrint('⚠️ Không có garage nào trong 5km, chuyển đợt 2 ngay lập tức');
        _startPhase2Scan(
          rescueRequestId: rescueRequestId,
          userLat: userLat,
          userLng: userLng,
        );
        return;
      }

      // Emit kết quả đợt 1
      debugPrint('📤 Emit Phase 1 result với ${nearbyGarages.length} garage(s)');
      _resultController?.add(ScanResult(
        phase: ScanPhase.phase1,
        garages: nearbyGarages,
      ));

      // Gửi rescue request đến các garage này
      await _notifyGarages(rescueRequestId, nearbyGarages);

      // Bắt đầu lắng nghe acceptance
      _listenForAcceptance(rescueRequestId);

      // Đặt timer 1 phút cho đợt 1
      debugPrint('⏰ Set timer 1 phút cho đợt 1');
      _phaseTimer = Timer(const Duration(minutes: 1), () {
        debugPrint('⏰ Hết thời gian đợt 1, chuyển sang đợt 2');
        _stopListeningAcceptance();
        _startPhase2Scan(
          rescueRequestId: rescueRequestId,
          userLat: userLat,
          userLng: userLng,
        );
      });

    } catch (e) {
      debugPrint('❌ Lỗi trong đợt 1: $e');
      _resultController?.addError('Lỗi quét garage đợt 1: $e');
    }
  }

  /// Đợt 2: Quét trong bán kính 10km
  Future<void> _startPhase2Scan({
    required String rescueRequestId,
    required double userLat,
    required double userLng,
  }) async {
    debugPrint('🔍 Bắt đầu đợt 2: Quét garage trong bán kính 10km');

    try {
      // Tìm garage trong bán kính 10km
      final nearbyGarages = await _findNearbyGarages(
        userLat: userLat,
        userLng: userLng,
        radiusKm: 10.0,
      );

      debugPrint('🏪 Đợt 2: Tìm thấy ${nearbyGarages.length} garage trong 10km');

      if (nearbyGarages.isEmpty) {
        debugPrint('❌ Không có garage nào trong 10km, kết thúc');
        _resultController?.add(ScanResult(
          phase: ScanPhase.failed,
          garages: [],
        ));
        dispose();
        return;
      }

      // Emit kết quả đợt 2
      _resultController?.add(ScanResult(
        phase: ScanPhase.phase2,
        garages: nearbyGarages,
      ));

      // Gửi rescue request đến các garage này
      await _notifyGarages(rescueRequestId, nearbyGarages);

      // Bắt đầu lắng nghe acceptance
      _listenForAcceptance(rescueRequestId);

      // Đặt timer 1 phút cho đợt 2
      _phaseTimer = Timer(const Duration(minutes: 1), () {
        debugPrint('⏰ Hết thời gian đợt 2, kết thúc');
        _resultController?.add(ScanResult(
          phase: ScanPhase.failed,
          garages: nearbyGarages,
        ));
        dispose();
      });

    } catch (e) {
      debugPrint('❌ Lỗi trong đợt 2: $e');
      _resultController?.addError('Lỗi quét garage đợt 2: $e');
    }
  }

  /// Tìm garage gần trong bán kính
  Future<List<GarageModel>> _findNearbyGarages({
    required double userLat,
    required double userLng,
    required double radiusKm,
  }) async {
    try {
      debugPrint('🔍 === BẮT ĐẦU TÌM GARAGE ===');
      debugPrint('📍 User position: lat=$userLat, lng=$userLng');
      debugPrint('📏 Radius: ${radiusKm}km');
      
      // Lấy tất cả garage active
      debugPrint('🔄 Đang query Firestore collection "garages"...');
      debugPrint('🔗 Firestore instance: $_firestore');
      debugPrint('⏰ Query time: ${DateTime.now()}');
      
      final snapshot = await _firestore
          .collection('garages')
          .where('isActive', isEqualTo: true)
          .get();
      
      debugPrint('📡 Firestore query completed successfully');
      debugPrint('⚡ Query took: ${DateTime.now().millisecondsSinceEpoch}ms');

      debugPrint('📊 Tìm thấy ${snapshot.docs.length} garage(s) active trong Firestore');

      final garages = <GarageModel>[];

      for (final doc in snapshot.docs) {
        try {
          debugPrint('\n🏪 === GARAGE ${doc.id} ===');
          debugPrint('📄 Raw data: ${doc.data()}');
          debugPrint('🔍 Document ID: ${doc.id}');
          debugPrint('📋 Document exists: ${doc.exists}');
          debugPrint('🗄️ Document metadata: ${doc.metadata}');
          
          final garage = GarageModel.fromMap(doc.id, doc.data());
          debugPrint('✅ GarageModel parsed successfully');
          debugPrint('🏷️ Name: ${garage.name}');
          debugPrint('📍 Garage position: lat=${garage.lat}, lng=${garage.lng}');
          debugPrint('� Phone: ${garage.phone}');
          debugPrint('🏪 Address: ${garage.address}');
          debugPrint('🟢 Is Active: ${garage.isActive}');
          
          if (garage.lat != null && garage.lng != null) {
            debugPrint('📍 Garage coordinates valid: lat=${garage.lat}, lng=${garage.lng}');
            debugPrint('📍 User coordinates: lat=$userLat, lng=$userLng');
            debugPrint('🧮 Calculating distance using Haversine formula...');
            
            final distance = _calculateDistance(
              userLat,
              userLng,
              garage.lat!,
              garage.lng!,
            );

            debugPrint('📏 Distance calculated: ${distance.toStringAsFixed(2)}km');
            debugPrint('🎯 Required radius: ${radiusKm}km');
            debugPrint('🔍 Within radius ${radiusKm}km? ${distance <= radiusKm ? "YES ✅" : "NO ❌"}');
            debugPrint('💡 Distance vs Radius: ${distance.toStringAsFixed(2)} <= ${radiusKm} = ${distance <= radiusKm}');

            if (distance <= radiusKm) {
              garages.add(garage.copyWith(distance: distance));
              debugPrint('✅ ADDED to result list');
            } else {
              debugPrint('❌ SKIPPED (too far)');
            }
          } else {
            debugPrint('⚠️ SKIPPED (missing lat/lng data)');
            debugPrint('   lat: ${garage.lat}, lng: ${garage.lng}');
          }
        } catch (e) {
          debugPrint('❌ Lỗi parse garage ${doc.id}: $e');
        }
      }

      // Sắp xếp theo khoảng cách gần nhất
      debugPrint('\n📋 === BEFORE SORTING ===');
      debugPrint('📊 Total garages before sort: ${garages.length}');
      for (int i = 0; i < garages.length; i++) {
        debugPrint('   ${i + 1}. ${garages[i].name}: ${garages[i].distance?.toStringAsFixed(2)}km');
      }
      
      garages.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
      
      debugPrint('\n📋 === AFTER SORTING ===');
      for (int i = 0; i < garages.length; i++) {
        debugPrint('   ${i + 1}. ${garages[i].name}: ${garages[i].distance?.toStringAsFixed(2)}km');
      }

      debugPrint('\n🏁 === KẾT QUẢ FINAL ===');
      debugPrint('✅ Found ${garages.length} garage(s) within ${radiusKm}km');
      for (var garage in garages) {
        debugPrint('   - ${garage.name}: ${garage.distance?.toStringAsFixed(2)}km');
      }
      debugPrint('=========================\n');

      return garages;
    } catch (e) {
      debugPrint('❌ Lỗi tìm garage gần: $e');
      return [];
    }
  }

  /// Tính khoảng cách giữa 2 điểm (Haversine formula)
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    debugPrint('🧮 === DISTANCE CALCULATION START ===');
    debugPrint('   📍 Point 1 (User): lat=$lat1, lng=$lng1');
    debugPrint('   📍 Point 2 (Garage): lat=$lat2, lng=$lng2');
    
    // Validate coordinates
    if (lat1 < -90 || lat1 > 90 || lat2 < -90 || lat2 > 90) {
      debugPrint('   ❌ Invalid latitude values detected!');
    }
    if (lng1 < -180 || lng1 > 180 || lng2 < -180 || lng2 > 180) {
      debugPrint('   ❌ Invalid longitude values detected!');
    }
    
    const p = 0.017453292519943295; // Math.PI / 180
    debugPrint('   🧮 Converting to radians with factor: $p');
    
    final latDiff = lat2 - lat1;
    final lngDiff = lng2 - lng1;
    debugPrint('   📏 Lat difference: $latDiff');
    debugPrint('   📏 Lng difference: $lngDiff');
    
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lng2 - lng1) * p)) / 2;
    debugPrint('   🧮 Haversine intermediate value a: $a');
    
    final distance = 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
    debugPrint('   ➡️ Final distance: ${distance.toStringAsFixed(4)}km');
    debugPrint('🧮 === DISTANCE CALCULATION END ===\n');
    
    return distance;
  }

  /// Tạo notification vào Firestore để garage có thể lắng nghe
  Future<void> _notifyGarages(String rescueRequestId, List<GarageModel> garages) async {
    debugPrint('📤 === BẮT ĐẦU GỬI THÔNG BÁO ===');
    debugPrint('🆔 Rescue Request ID: $rescueRequestId');
    debugPrint('🏪 Số lượng garage: ${garages.length}');
    debugPrint('⏰ Thời gian: ${DateTime.now()}');
    
    if (garages.isEmpty) {
      debugPrint('⚠️ Không có garage nào để gửi thông báo!');
      return;
    }
    
    try {
      // Batch write để tăng hiệu suất
      final batch = _firestore.batch();
      
      for (final garage in garages) {
        final notificationRef = _firestore
            .collection('garage_notifications')
            .doc(garage.id)
            .collection('rescue_requests')
            .doc(rescueRequestId);
            
        batch.set(notificationRef, {
          'rescueRequestId': rescueRequestId,
          'garageId': garage.id,
          'distance': garage.distance,
          'notifiedAt': FieldValue.serverTimestamp(),
          'status': 'notified', // notified, viewed, accepted, expired
          'expiresAt': DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch,
        });

        debugPrint('  📧 -> ${garage.name} (${garage.distance?.toStringAsFixed(1)}km)');
      }

      // Execute batch
      await batch.commit();
      debugPrint('✅ Batch notification commit thành công');

      // TODO: Có thể thêm push notification ở đây
      // await _sendPushNotification(garages, rescueRequestId);
      
    } catch (e) {
      debugPrint('❌ Lỗi gửi notification: $e');
    }
  }

  /// Background task để cleanup expired notifications
  static Future<void> cleanupExpiredNotifications() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final cutoffTime = DateTime.now().subtract(const Duration(minutes: 10));
      
      // Query tất cả garage có notifications
      final garageSnapshot = await firestore.collection('garage_notifications').get();
      
      int cleanedCount = 0;
      
      for (final garageDoc in garageSnapshot.docs) {
        final expiredSnapshot = await garageDoc.reference
            .collection('rescue_requests')
            .where('expiresAt', isLessThan: cutoffTime.millisecondsSinceEpoch)
            .where('status', whereIn: ['notified', 'viewed'])
            .get();
            
        if (expiredSnapshot.docs.isNotEmpty) {
          final batch = firestore.batch();
          
          for (final doc in expiredSnapshot.docs) {
            batch.delete(doc.reference);
          }
          
          await batch.commit();
          cleanedCount += expiredSnapshot.docs.length;
        }
      }
      
      debugPrint('🧹 Background cleanup: Xóa $cleanedCount expired notifications');
    } catch (e) {
      debugPrint('❌ Lỗi background cleanup: $e');
    }
  }

  /// Lắng nghe garage acceptance
  void _listenForAcceptance(String rescueRequestId) {
    _acceptanceSubscription?.cancel();
    
    _acceptanceSubscription = _firestore
        .collection('rescue_requests')
        .doc(rescueRequestId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final data = doc.data();
        final status = data?['status'];
        
        if (status == 'accepted') {
          debugPrint('✅ Garage đã nhận rescue request!');
          
          _resultController?.add(ScanResult(
            phase: ScanPhase.completed,
            garages: [],
            hasAcceptance: true,
            acceptedGarageId: data?['garageId'],
            acceptedGarageName: data?['name'],
          ));
          
          dispose();
        }
      }
    });
  }

  void _stopListeningAcceptance() {
    _acceptanceSubscription?.cancel();
    _acceptanceSubscription = null;
  }

  /// Dọn dẹp resources
  void dispose() {
    _phaseTimer?.cancel();
    _phaseTimer = null;
    
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    
    _stopListeningAcceptance();
    
    _resultController?.close();
    _resultController = null;
    
    debugPrint('🧹 GarageScannerService đã được dọn dẹp');
  }
}