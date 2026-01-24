import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';

/// Quản lý trạng thái rescue request hiện tại
final currentRescueRequestNotifierProvider =
    StateNotifierProvider<CurrentRescueRequestNotifier, RescueRequestModel?>(
  (ref) => CurrentRescueRequestNotifier(),
);

class CurrentRescueRequestNotifier
    extends StateNotifier<RescueRequestModel?> {
  CurrentRescueRequestNotifier() : super(null);

  void setCurrentRescueRequest(RescueRequestModel? request) {
    state = request;
  }

  void clearCurrentRescueRequest() {
    state = null;
  }
}

/// Quản lý trạng thái rescue navigation
final rescueNavigationScreenProvider =
    StateNotifierProvider<RescueNavigationNotifier, String?>(
  (ref) => RescueNavigationNotifier(),
);

class RescueNavigationNotifier extends StateNotifier<String?> {
  RescueNavigationNotifier() : super(null);

  // Screens
  static const String rescueRequest = 'rescue_request';
  static const String rescueWaiting = 'rescue_waiting';
  static const String rescueSuccess = 'rescue_success';
  static const String rescueNoGarage = 'rescue_no_garage';

  void navigateToWaiting(String requestId) {
    state = rescueWaiting;
  }

  void navigateToSuccess(String requestId) {
    state = rescueSuccess;
  }

  void navigateToNoGarage(String requestId) {
    state = rescueNoGarage;
  }

  void backToRescueRequest() {
    state = rescueRequest;
  }
}
