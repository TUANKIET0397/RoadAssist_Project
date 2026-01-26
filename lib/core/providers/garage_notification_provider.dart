import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_viewmodel.dart';

/// Provider để garage nhận rescue request từ notification system
/// Thay thế cho logic quét tự động cũ
final notifiedRescueRequestsProvider = StreamProvider.family
    .autoDispose<List<RescueRequestModel>, String>((ref, garageId) {
  
  final firestore = FirebaseFirestore.instance;
  final repo = ref.watch(rescueRequestRepoProvider);
  
  return firestore
      .collection('garage_notifications')
      .doc(garageId)
      .collection('rescue_requests')
      .orderBy('notifiedAt', descending: true)
      .snapshots()
      .asyncMap((notificationSnapshot) async {
    
    debugPrint('🔔 Garage $garageId nhận ${notificationSnapshot.docs.length} notifications');
    
    if (notificationSnapshot.docs.isEmpty) {
      return <RescueRequestModel>[];
    }

    // Filter by status in memory instead of query
    final validNotifications = notificationSnapshot.docs
        .where((doc) => doc.data()['status'] == 'notified')
        .toList();
    
    if (validNotifications.isEmpty) {
      return <RescueRequestModel>[];
    }

    // Lấy rescue request IDs từ notifications  
    final rescueRequestIds = validNotifications
        .map((doc) => doc.data()['rescueRequestId'] as String)
        .toList();

    debugPrint('📋 Valid rescue request IDs: $rescueRequestIds');

    // Fetch rescue request details
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
            debugPrint('✅ Loaded rescue request: ${rescueRequest.id} - ${rescueRequest.vehicleType}');
          } else {
            debugPrint('⚠️ Rescue request $requestId không còn pending, bỏ qua');
          }
        } else {
          debugPrint('⚠️ Rescue request $requestId không tồn tại');
        }
      } catch (e) {
        debugPrint('❌ Lỗi load rescue request $requestId: $e');
      }
    }

    debugPrint('📦 Garage $garageId có ${rescueRequests.length} rescue requests active');
    return rescueRequests;
  });
});

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
      
      debugPrint('✅ Marked notification viewed: garage=$garageId, request=$rescueRequestId');
    } catch (e) {
      debugPrint('❌ Lỗi mark notification viewed: $e');
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
      
      debugPrint('✅ Marked notification accepted: garage=$garageId, request=$rescueRequestId');
    } catch (e) {
      debugPrint('❌ Lỗi mark notification accepted: $e');
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
      
      debugPrint('🧹 Cleaned up ${expiredDocs.docs.length} expired notifications for garage $garageId');
    } catch (e) {
      debugPrint('❌ Lỗi cleanup notifications: $e');
    }
  }
}