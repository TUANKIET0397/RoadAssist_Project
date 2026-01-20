import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/garage_model.dart';

// ViewModel State
class GarageSuccessState {
  final GarageModel garage;
  final bool isLoading;
  final String? errorMessage;

  GarageSuccessState({
    required this.garage,
    this.isLoading = false,
    this.errorMessage,
  });

  GarageSuccessState copyWith({
    GarageModel? garage,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GarageSuccessState(
      garage: garage ?? this.garage,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Helpers
  String get openStatus {
    if (!garage.isActive) return 'Đang đóng cửa';

    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

    final openTimeParts = garage.openTime.split(':');
    final closeTimeParts = garage.closeTime.split(':');

    final openTime = TimeOfDay(
      hour: int.parse(openTimeParts[0]),
      minute: int.parse(openTimeParts[1]),
    );

    final closeTime = TimeOfDay(
      hour: int.parse(closeTimeParts[0]),
      minute: int.parse(closeTimeParts[1]),
    );

    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final openMinutes = openTime.hour * 60 + openTime.minute;
    final closeMinutes = closeTime.hour * 60 + closeTime.minute;

    if (currentMinutes >= openMinutes && currentMinutes <= closeMinutes) {
      return 'Đang mở cửa';
    }

    return 'Đang đóng cửa';
  }

  String get openHours => '${garage.openTime} - ${garage.closeTime}';
}

// ViewModel
class GarageSuccessViewModel extends StateNotifier<GarageSuccessState> {
  GarageSuccessViewModel(GarageModel garage)
      : super(GarageSuccessState(garage: garage));

  void updateGarageInfo() async {
    state = state.copyWith(isLoading: true);

    try {
      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Có lỗi xảy ra: $e',
      );
    }
  }

  void toggleFavorite() {
    final updatedGarage = GarageModel(
      id: state.garage.id,
      name: state.garage.name,
      distance: state.garage.distance,
      address: state.garage.address,
      phone: state.garage.phone,
      vehicleTypes: state.garage.vehicleTypes,
      issues: state.garage.issues,
      openTime: state.garage.openTime,
      closeTime: state.garage.closeTime,
      lat: state.garage.lat,
      lng: state.garage.lng,
      rating: state.garage.rating,
      isActive: state.garage.isActive,
      imageUrl: state.garage.imageUrl,
      bgimgUrl: state.garage.bgimgUrl,
      isFavorite: !state.garage.isFavorite,
    );

    state = state.copyWith(garage: updatedGarage);
  }
}

// Provider
final garageSuccessVMProvider = StateNotifierProvider.autoDispose
    .family<GarageSuccessViewModel, GarageSuccessState, GarageModel>(
      (ref, garage) => GarageSuccessViewModel(garage),
);