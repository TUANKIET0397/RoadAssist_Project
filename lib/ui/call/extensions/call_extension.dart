import 'package:flutter/material.dart';
import 'package:road_assist/ui/call/services/call_initiation_service.dart';
import 'package:road_assist/ui/call/screens/waiting_call_screen.dart';

extension CallHelper on BuildContext {
  /// Gọi một garage từ bất kỳ screen nào (User gọi Garage)
  /// Ví dụ: context.callGarage('garage_uid', 'Garage Name')
  Future<void> callGarage(
    String garageUid, {
    String garageName = 'Garage',
  }) async {
    try {
      final callId =
          await CallInitiationService().initiateCallToGarage(garageUid: garageUid);

      if (mounted) {
        Navigator.of(this).push(
          MaterialPageRoute(
            builder: (_) => WaitingCallScreen(
              callId: callId,
              receiverUid: garageUid,
              receiverName: garageName,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(this).showSnackBar(
          SnackBar(content: Text('Lỗi gọi: $e')),
        );
      }
    }
  }

  /// Gọi một user từ bất kỳ screen nào (Garage gọi User)
  /// Ví dụ: context.callUser('user_uid', 'User Name')
  Future<void> callUser(
    String userId, {
    String userName = 'User',
  }) async {
    try {
      final callId =
          await CallInitiationService().initiateCallToUser(userId: userId);

      if (mounted) {
        Navigator.of(this).push(
          MaterialPageRoute(
            builder: (_) => WaitingCallScreen(
              callId: callId,
              receiverUid: userId,
              receiverName: userName,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(this).showSnackBar(
          SnackBar(content: Text('Lỗi gọi: $e')),
        );
      }
    }
  }
}
