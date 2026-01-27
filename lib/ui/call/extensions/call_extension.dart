import 'package:flutter/material.dart';
import 'package:road_assist/ui/call/services/call_initiation_service.dart';
import 'package:road_assist/ui/call/screens/waiting_call_screen.dart';

extension CallHelper on BuildContext {
  /// Gọi một garage từ bất kỳ screen nào
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
              garageUid: garageUid,
              garageName: garageName,
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
