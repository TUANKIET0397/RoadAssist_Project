import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final rescueServiceProvider = Provider((ref) {
  return RescueService();
});

class RescueService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Update rescue request progress step
  /// [rescueRequestId] - ID của yêu cầu cứu hộ
  /// [progressStep] - Bước tiến độ (1: nhận, 2: đến nơi, 3: sửa chữa, 4: hoàn thành)
  Future<void> updateRescueProgress(
    String rescueRequestId,
    int progressStep,
  ) async {
    try {
      // Validation
      if (progressStep < 1 || progressStep > 4) {
        throw Exception('Invalid progress step: $progressStep');
      }

      if (rescueRequestId.isEmpty) {
        throw Exception('Invalid rescue request ID');
      }

      final now = Timestamp.now();
      final Map<String, dynamic> updateData = {
        'progressStep': progressStep,
      };

      // Add timestamp for each step
      switch (progressStep) {
        case 1:
          updateData['acceptedAt'] = now;
          break;
        case 2:
          updateData['arrivedAt'] = now;
          break;
        case 3:
          updateData['repairingStartedAt'] = now;
          break;
        case 4:
          updateData['completedAt'] = now;
          updateData['status'] = 'completed';
          break;
      }

      print('🔄 Updating rescue progress: $rescueRequestId to step $progressStep');
      
      await _firestore
          .collection('rescue_requests')
          .doc(rescueRequestId)
          .update(updateData);
      
      print(' Update success');
    } catch (e) {
      print(' Error updating rescue progress: $e');
      throw Exception('Failed to update rescue progress: $e');
    }
  }

  /// Get real-time updates for a rescue request
  Stream<Map<String, dynamic>?> watchRescueRequest(String rescueRequestId) {
    return _firestore
        .collection('rescue_requests')
        .doc(rescueRequestId)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  /// Get rescue request by ID
  Future<Map<String, dynamic>?> getRescueRequest(String rescueRequestId) async {
    try {
      final snapshot = await _firestore
          .collection('rescue_requests')
          .doc(rescueRequestId)
          .get();
      return snapshot.data();
    } catch (e) {
      throw Exception('Failed to get rescue request: $e');
    }
  }
}
