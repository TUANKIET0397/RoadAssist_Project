import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';

/// Provider để garage nhận rescue request từ notification system
/// Tự động cập nhật khi:
/// 1. Notification thay đổi (garage_notifications)
/// 2. Rescue request status thay đổi (rescue_requests) - ví dụ user hủy
final notifiedRescueRequestsProvider = StreamProvider.family
    .autoDispose<List<RescueRequestModel>, String>((ref, garageId) {
  
  final firestore = FirebaseFirestore.instance;
  
  // Controller để emit combined results
  final controller = StreamController<List<RescueRequestModel>>();
  
  // Cache các request IDs hiện tại để listen
  Set<String> currentRequestIds = {};
  List<StreamSubscription> requestSubscriptions = [];
  
  // Listen notification changes
  final notificationSubscription = firestore
      .collection('garage_notifications')
      .doc(garageId)
      .collection('rescue_requests')
      .where('status', isEqualTo: 'notified')
      .orderBy('notifiedAt', descending: true)
      .snapshots()
      .listen((notificationSnapshot) async {
    
    debugPrint('🔔 Garage $garageId nhận ${notificationSnapshot.docs.length} notifications');
    
    if (notificationSnapshot.docs.isEmpty) {
      currentRequestIds = {};
      controller.add(<RescueRequestModel>[]);
      return;
    }

    // Lấy rescue request IDs từ notifications  
    final rescueRequestIds = notificationSnapshot.docs
        .map((doc) => doc.data()['rescueRequestId'] as String)
        .toSet();

    debugPrint('📋 Rescue request IDs: $rescueRequestIds');
    
    // Nếu có request IDs mới, setup listeners cho chúng
    if (!_setEquals(currentRequestIds, rescueRequestIds)) {
      currentRequestIds = rescueRequestIds;
      
      // Cancel old subscriptions
      for (final sub in requestSubscriptions) {
        sub.cancel();
      }
      requestSubscriptions.clear();
      
      // Setup real-time listeners cho từng rescue request
      for (final requestId in rescueRequestIds) {
        final sub = firestore
            .collection('rescue_requests')
            .doc(requestId)
            .snapshots()
            .listen((requestDoc) async {
          // Khi bất kỳ request nào thay đổi, fetch lại tất cả
          await _fetchAndEmitRequests(firestore, garageId, rescueRequestIds, controller);
        });
        requestSubscriptions.add(sub);
      }
    }
    
    // Fetch initial data
    await _fetchAndEmitRequests(firestore, garageId, rescueRequestIds, controller);
  });
  
  // Cleanup khi dispose
  ref.onDispose(() {
    notificationSubscription.cancel();
    for (final sub in requestSubscriptions) {
      sub.cancel();
    }
    controller.close();
  });
  
  return controller.stream;
});

/// Helper để so sánh 2 sets
bool _setEquals<T>(Set<T> a, Set<T> b) {
  if (a.length != b.length) return false;
  for (final item in a) {
    if (!b.contains(item)) return false;
  }
  return true;
}

/// Helper function để fetch và emit rescue requests
Future<void> _fetchAndEmitRequests(
  FirebaseFirestore firestore,
  String garageId,
  Set<String> rescueRequestIds,
  StreamController<List<RescueRequestModel>> controller,
) async {
  final rescueRequests = <RescueRequestModel>[];
  
  for (final requestId in rescueRequestIds) {
    try {
      final requestDoc = await firestore
          .collection('rescue_requests')
          .doc(requestId)
          .get();
          
      if (requestDoc.exists) {
        final data = requestDoc.data();
        if (data != null && data['status'] == 'pending') {
          final rescueRequest = RescueRequestModel.fromMap(requestId, data);
          rescueRequests.add(rescueRequest);
          debugPrint(' Loaded rescue request: ${rescueRequest.id} - ${rescueRequest.vehicleType}');
        } else {
          debugPrint(' Rescue request $requestId không còn pending (status: ${data?['status']}), bỏ qua');
          // Xóa notification cho request không còn pending
          _cleanupStaleNotification(garageId, requestId);
        }
      } else {
        debugPrint(' Rescue request $requestId không tồn tại');
        // Xóa notification cho request không tồn tại
        _cleanupStaleNotification(garageId, requestId);
      }
    } catch (e) {
      debugPrint(' Lỗi load rescue request $requestId: $e');
    }
  }
  
  debugPrint(' Garage $garageId có ${rescueRequests.length} rescue requests active');
  
  if (!controller.isClosed) {
    controller.add(rescueRequests);
  }
}

/// Helper function để xóa notifications cho requests không còn valid
Future<void> _cleanupStaleNotification(String garageId, String requestId) async {
  try {
    await FirebaseFirestore.instance
        .collection('garage_notifications')
        .doc(garageId)
        .collection('rescue_requests')
        .doc(requestId)
        .delete();
    debugPrint(' Đã xóa notification cũ cho request: $requestId');
  } catch (e) {
    debugPrint(' Lỗi xóa notification cũ: $e');
  }
}

/// Provider để mark notification đã xem
final notificationActionProvider = Provider((ref) {
  return NotificationActionService();
});

class NotificationActionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Mark notification đã được xem 
  Future<void> markNotificationViewed({
    required String garageId,
    required String rescueRequestId,
  }) async {
    try {
      await _firestore
          .collection('garage_notifications')
          .doc(garageId)
          .collection('rescue_requests')
          .doc(rescueRequestId)
          .update({
        'status': 'viewed',
        'viewedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint(' Marked notification viewed: garage=$garageId, request=$rescueRequestId');
    } catch (e) {
      debugPrint(' Lỗi mark notification viewed: $e');
    }
  }

  /// Mark notification đã được accept (để cleanup)
  Future<void> markNotificationAccepted({
    required String garageId,
    required String rescueRequestId,
  }) async {
    try {
      await _firestore
          .collection('garage_notifications')
          .doc(garageId)
          .collection('rescue_requests')
          .doc(rescueRequestId)
          .update({
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint(' Marked notification accepted: garage=$garageId, request=$rescueRequestId');
    } catch (e) {
      debugPrint(' Lỗi mark notification accepted: $e');
    }
  }

  /// Từ chối request - CHỈ xóa notification của garage này
  /// KHÔNG ảnh hưởng đến các garage khác và KHÔNG thay đổi rescue_request status
  Future<void> rejectNotification({
    required String garageId,
    required String rescueRequestId,
  }) async {
    try {
      // Chỉ xóa notification của garage này
      await _firestore
          .collection('garage_notifications')
          .doc(garageId)
          .collection('rescue_requests')
          .doc(rescueRequestId)
          .delete();
      
      debugPrint(' Rejected & deleted notification: garage=$garageId, request=$rescueRequestId');
      debugPrint(' Các garage khác vẫn có thể nhận request này');
    } catch (e) {
      debugPrint(' Lỗi reject notification: $e');
      rethrow;
    }
  }

  /// Cleanup expired notifications (optional background task)
  Future<void> cleanupExpiredNotifications(String garageId) async {
    try {
      final cutoff = DateTime.now().subtract(const Duration(minutes: 5));
      
      final expiredDocs = await _firestore
          .collection('garage_notifications')
          .doc(garageId)
          .collection('rescue_requests')
          .where('notifiedAt', isLessThan: Timestamp.fromDate(cutoff))
          .where('status', isEqualTo: 'notified')
          .get();

      for (final doc in expiredDocs.docs) {
        await doc.reference.update({
          'status': 'expired',
          'expiredAt': FieldValue.serverTimestamp(),
        });
      }
      
      debugPrint(' Cleaned up ${expiredDocs.docs.length} expired notifications for garage $garageId');
    } catch (e) {
      debugPrint(' Lỗi cleanup notifications: $e');
    }
  }
}