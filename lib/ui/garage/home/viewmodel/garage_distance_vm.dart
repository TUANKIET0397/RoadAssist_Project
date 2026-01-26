import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:road_assist/core/services/gps/location_geolocator.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';

/// STATE
class GarageHomeState {
  final double? garageLat;
  final double? garageLng;
  final bool isLoading;
  final String? error;

  const GarageHomeState({
    this.garageLat,
    this.garageLng,
    this.isLoading = false,
    this.error,
  });

  GarageHomeState copyWith({
    double? garageLat,
    double? garageLng,
    bool? isLoading,
    String? error,
  }) {
    return GarageHomeState(
      garageLat: garageLat ?? this.garageLat,
      garageLng: garageLng ?? this.garageLng,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// VIEW MODEL

class GarageHomeViewModel extends StateNotifier<GarageHomeState> {
  GarageHomeViewModel() : super(const GarageHomeState());

  Future<void> initGarageLocation() async {
    // nếu đã có thì KHÔNG gọi lại GPS
    if (state.garageLat != null && state.garageLng != null) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final Position position =
      await LocationService.getCurrentPosition();

      state = state.copyWith(
        garageLat: position.latitude,
        garageLng: position.longitude,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// TÍNH KHOẢNG CÁCH
  double? calculateDistanceToRequest(RescueRequestModel request) {
    if (state.garageLat == null || state.garageLng == null) {
      return null;
    }

    return LocationService.calculateDistanceKm(
      garageLat: state.garageLat!,
      garageLng: state.garageLng!,
      userLat: request.latitude,
      userLng: request.longitude,
    );
  }
}

/// PROVIDER
final garageHomeViewModelProvider =
StateNotifierProvider<GarageHomeViewModel, GarageHomeState>(
      (ref) => GarageHomeViewModel(),
);
