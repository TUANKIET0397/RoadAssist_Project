import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:road_assist/core/services/gps/location_geolocator.dart';
import 'package:road_assist/data/models/garage_model.dart';
import 'package:road_assist/ui/user/garage/viewmodel/garageDetail_viewmodel.dart';

/// State của garage
class GarageState {
  final bool isLoading;
  final List<GarageModel> garages;
  final String? error;


  GarageState({
    required this.isLoading,
    required this.garages,
    this.error,
  });

  factory GarageState.initial() {
    return GarageState(
      isLoading: false,
      garages: [],
    );
  }

  GarageState copyWith({
    bool? isLoading,
    List<GarageModel>? garages,
    String? error,
  }) {
    return GarageState(
      isLoading: isLoading ?? this.isLoading,
      garages: garages ?? this.garages,
      error: error,
    );
  }
}

/// StateNotifier quản lý garage
class GarageNotifier extends StateNotifier<GarageState> {
  final FirebaseFirestore _firestore;
  final LocationService _locationService;

  GarageNotifier(
      this._firestore,
      this._locationService,
      ) : super(GarageState.initial());

  /// Lấy danh sách garage + tính distance
  Future<void> fetchGarages() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final snapshot = await _firestore
          .collection('garages')
          .where('isActive', isEqualTo: true)
          .get();

      final garages = snapshot.docs
          .map((doc) => GarageModel.fromMap(doc.id, doc.data()))
          .toList();

      // Gắn distance (GPS)
      final garagesWithDistance =
      await _locationService.calculateDistanceForGarages(garages);

      // Sort theo distance
      garagesWithDistance.sort((a, b) {
        if (a.distance == null) return 1;
        if (b.distance == null) return -1;
        return a.distance!.compareTo(b.distance!);
      });

      // Update state
      state = state.copyWith(
        garages: garagesWithDistance,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Lỗi load garages: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Toggle favorite garage
  Future<void> toggleFavorite({
    required String userId,
    required GarageModel garage,
  }) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(garage.id);

    try {
      if (garage.isFavorite) {
        await docRef.delete();
      } else {
        await docRef.set({
          'garageId': garage.id,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final updatedGarages = state.garages.map((g) {
        if (g.id == garage.id) {
          return g.copyWith(isFavorite: !g.isFavorite);
        }
        return g;
      }).toList();

      state = state.copyWith(garages: updatedGarages);
    } catch (e) {
      debugPrint('Lỗi toggle favorite: $e');
    }
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Riverpod provider
final garageProvider =
StateNotifierProvider<GarageNotifier, GarageState>((ref) {
  return GarageNotifier(
    FirebaseFirestore.instance,
    ref.read(locationServiceProvider),
  );
});

final garageDetailProvider = StateNotifierProvider.family<
    GarageDetailNotifier,
    GarageDetailState,
    String>(
      (ref, garageId) {
    final notifier = GarageDetailNotifier();
    notifier.watchGarageReviews(garageId);
    return notifier;
  },
);


