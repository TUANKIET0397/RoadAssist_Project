import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/user/rescue/view/rescueRequest_screen.dart';
import 'package:road_assist/ui/user/rescue/view/user_rescue_waiting_screen.dart';
import 'package:road_assist/ui/user/rescue/view/user_rescue_success_screen.dart';
import 'package:road_assist/ui/user/rescue/view/user_rescue_no_garage_screen_new.dart' as ng_screen;
import 'package:road_assist/data/models/garage_model.dart';

class RescueScreenWrapper extends ConsumerStatefulWidget {
  const RescueScreenWrapper({super.key});

  @override
  ConsumerState<RescueScreenWrapper> createState() =>
      _RescueScreenWrapperState();
}

class _RescueScreenWrapperState extends ConsumerState<RescueScreenWrapper> {
  String currentScreen = 'rescue_request';
  String? currentRequestId;
  String? garageId;
  String? garageName;
  List<GarageModel> scannedGarages = [];
 // RescueRequestModel? _currentRequestData;

  void _navigateToWaiting(String requestId) {
    setState(() {
      currentScreen = 'rescue_waiting';
      currentRequestId = requestId;
    });
  }

  void _navigateToSuccess(String requestId, String? garageId, String? garageName) {
    setState(() {
      currentScreen = 'rescue_success';
      currentRequestId = requestId;
      this.garageId = garageId;
      this.garageName = garageName;
    });
  }

  void _navigateToNoGarage(String requestId, [List<GarageModel>? garages]) {
    setState(() {
      currentScreen = 'rescue_no_garage';
      currentRequestId = requestId;
      scannedGarages = garages ?? [];
    });
  }

  void _backToRequest() {
    setState(() {
      currentScreen = 'rescue_request';
      currentRequestId = null;
      garageId = null;
      garageName = null;
      scannedGarages = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (currentScreen) {
      case 'rescue_waiting':
        return UserRescueWaitingScreen(
          rescueRequestId: currentRequestId!,
          onNavigateToSuccess: _navigateToSuccess,
          onNavigateToNoGarage: _navigateToNoGarage,
          onBack: _backToRequest,
        );
      case 'rescue_success':
        return UserRescueSuccessScreen(
          rescueRequestId: currentRequestId!,
          garageId: garageId,
          garageName: garageName,
          onBack: _backToRequest,
         // request: _currentRequestData, // Can be null, it will fetch from Firebase
        );
      case 'rescue_no_garage':
        return ng_screen.UserRescueNoGarageScreen(
          rescueRequestId: currentRequestId,
          scannedGarages: scannedGarages,
          onBack: _backToRequest,
        );
      case 'rescue_request':
      default:
        return RescueRequestScreen(
          onNavigateToWaiting: _navigateToWaiting,
        );
    }
  }
}
