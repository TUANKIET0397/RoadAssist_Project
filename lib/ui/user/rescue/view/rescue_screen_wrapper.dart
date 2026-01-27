import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/user/rescue/view/rescueRequest_screen.dart';
import 'package:road_assist/ui/user/rescue/view/user_rescue_waiting_screen.dart';
import 'package:road_assist/ui/user/rescue/view/user_rescue_success_screen.dart';
import 'package:road_assist/ui/user/rescue/view/user_rescue_no_garage_screen_new.dart' as ng_screen;
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_navigation_provider.dart';

/// Wrapper điều hướng các màn hình trong rescue flow
/// Sử dụng provider để quản lý state thay vì setState + callbacks
class RescueScreenWrapper extends ConsumerWidget {
  const RescueScreenWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(rescueNavigationProvider);

    switch (navState.currentScreen) {
      case RescueScreen.waiting:
        return UserRescueWaitingScreen(
          rescueRequestId: navState.rescueRequestId!,
        );
      case RescueScreen.success:
        return UserRescueSuccessScreen(
          rescueRequestId: navState.rescueRequestId!,
          garageId: navState.garageId,
          garageName: navState.garageName,
        );
      case RescueScreen.noGarage:
        return ng_screen.UserRescueNoGarageScreen(
          rescueRequestId: navState.rescueRequestId,
          scannedGarages: navState.scannedGarages,
        );
      case RescueScreen.request:
        return const RescueRequestScreen();
    }
  }
}
