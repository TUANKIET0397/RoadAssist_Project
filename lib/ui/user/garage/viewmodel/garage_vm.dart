import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:road_assist/core/services/gps/location_geolocator.dart';
import 'package:road_assist/data/models/garage_model.dart';

class GarageState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final List<GarageModel> garages;
  final String? error;

  GarageState({
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.garages,
    this.error,
  });

  factory GarageState.initial() {
    return GarageState(
      isLoading: false,
      isLoadingMore: false,
      hasMore: true,
      garages: [],
    );
  }

  GarageState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    List<GarageModel>? garages,
    String? error,
  }) {
    return GarageState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      garages: garages ?? this.garages,
      error: error,
    );
  }
}

class GarageNotifier extends StateNotifier<GarageState> {
  final FirebaseFirestore _firestore;
  final LocationService _locationService;

  DocumentSnapshot? _lastDoc;
  static const int _pageSize = 10;

  GarageNotifier(this._firestore, this._locationService)
      : super(GarageState.initial());

  Future<void> fetchGarages() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final snapshot = await _firestore
          .collection('garages')
          .where('isActive', isEqualTo: true)
          .limit(_pageSize)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _lastDoc = snapshot.docs.last;
      }

      final garages = snapshot.docs
          .map((doc) => GarageModel.fromMap(doc.id, doc.data()))
          .toList();

      final withDistance = await _locationService.calculateDistanceForGarages(garages);

      withDistance.sort((a, b) {
        if (a.distance == null && b.distance == null) return 0;
        if (a.distance == null) return 1;
        if (b.distance == null) return -1;
        return a.distance!.compareTo(b.distance!);
      });

      state = state.copyWith(
        garages: withDistance,
        isLoading: false,
        hasMore: snapshot.docs.length == _pageSize,
      );
    } catch (e) {
      debugPrint('Fetch error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || _lastDoc == null) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final snapshot = await _firestore
          .collection('garages')
          .where('isActive', isEqualTo: true)
          .startAfterDocument(_lastDoc!)
          .limit(_pageSize)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _lastDoc = snapshot.docs.last;
      }

      final garages = snapshot.docs
          .map((doc) => GarageModel.fromMap(doc.id, doc.data()))
          .toList();

      final withDistance =
      await _locationService.calculateDistanceForGarages(garages);

      withDistance.sort((a, b) {
        if (a.distance == null && b.distance == null) return 0;
        if (a.distance == null) return 1;
        if (b.distance == null) return -1;
        return a.distance!.compareTo(b.distance!);
      });

      state = state.copyWith(
        garages: withDistance,
        isLoading: false,
        hasMore: snapshot.docs.length == _pageSize,
      );

    } catch (e) {
      debugPrint('Load more error: $e');
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> toggleFavorite({
    required String userId,
    required GarageModel garage,
  }) async {
    try {
      final updatedGarage = garage.copyWith(isFavorite: !garage.isFavorite);

      final updatedGarages = state.garages.map((g) {
        return g.id == garage.id ? updatedGarage : g;
      }).toList();

      state = state.copyWith(garages: updatedGarages);

      if (updatedGarage.isFavorite) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc(garage.id)
            .set({'garageId': garage.id, 'createdAt': FieldValue.serverTimestamp()});
      } else {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc(garage.id)
            .delete();
      }
    } catch (e) {
      debugPrint('Toggle favorite error: $e');
      // Revert on error
      final revertedGarages = state.garages.map((g) {
        return g.id == garage.id ? garage : g;
      }).toList();
      state = state.copyWith(garages: revertedGarages);
    }
  }
}

// Rating/Review State
class GarageDetailState {
  final double averageRating;
  final int totalReviews;
  final bool isLoading;

  GarageDetailState({
    required this.averageRating,
    required this.totalReviews,
    this.isLoading = false,
  });

  factory GarageDetailState.initial() {
    return GarageDetailState(
      averageRating: 0.0,
      totalReviews: 0,
      isLoading: true,
    );
  }

  GarageDetailState copyWith({
    double? averageRating,
    int? totalReviews,
    bool? isLoading,
  }) {
    return GarageDetailState(
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class GarageDetailNotifier extends StateNotifier<GarageDetailState> {
  final FirebaseFirestore _firestore;
  final String garageId;

  GarageDetailNotifier(this._firestore, this.garageId)
      : super(GarageDetailState.initial()) {
    _fetchRatings();
  }

  Future<void> _fetchRatings() async {
    try {
      final snapshot = await _firestore
          .collection('garages')
          .doc(garageId)
          .collection('reviews')
          .get();

      if (snapshot.docs.isEmpty) {
        state = state.copyWith(
          averageRating: 0.0,
          totalReviews: 0,
          isLoading: false,
        );
        return;
      }

      double totalRating = 0.0;
      for (var doc in snapshot.docs) {
        totalRating += (doc.data()['rating'] as num?)?.toDouble() ?? 0.0;
      }

      state = state.copyWith(
        averageRating: totalRating / snapshot.docs.length,
        totalReviews: snapshot.docs.length,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Fetch ratings error: $e');
      state = state.copyWith(isLoading: false);
    }
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final garageProvider =
StateNotifierProvider<GarageNotifier, GarageState>((ref) {
  return GarageNotifier(
    FirebaseFirestore.instance,
    ref.read(locationServiceProvider),
  );
});

// Provider for garage detail (ratings/reviews)
final garageDetailProvider = StateNotifierProvider.family<GarageDetailNotifier,
    GarageDetailState, String>((ref, garageId) {
  return GarageDetailNotifier(
    FirebaseFirestore.instance,
    garageId,
  );
});