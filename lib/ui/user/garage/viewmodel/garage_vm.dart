import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:road_assist/data/models/garage_model.dart';

/// State của garage
class GarageState {
  final bool isLoading;
  final List<GarageModel> garages;
  final String? error;

  GarageState({required this.isLoading, required this.garages, this.error});

  factory GarageState.initial() => GarageState(isLoading: false, garages: []);

  GarageState copyWith({
    bool? isLoading,
    List<GarageModel>? garages,
    String? error,
  }) {
    return GarageState(
      isLoading: isLoading ?? this.isLoading,
      garages: garages ?? this.garages,
      error: error ?? this.error,
    );
  }
}

/// StateNotifier quản lý garage
class GarageNotifier extends StateNotifier<GarageState> {
  GarageNotifier() : super(GarageState.initial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy danh sách garage
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

      state = state.copyWith(garages: garages, isLoading: false);
    } catch (e) {
      debugPrint('Lỗi load garages: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
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
        garage.isFavorite = false;
      } else {
        await docRef.set({
          'garageId': garage.id,
          'createdAt': FieldValue.serverTimestamp(),
        });
        garage.isFavorite = true;
      }

      // update state để UI refresh
      state = state.copyWith(garages: [...state.garages]);
    } catch (e) {
      debugPrint('Lỗi toggle favorite: $e');
    }
  }
}

/// Riverpod provider
final garageProvider = StateNotifierProvider<GarageNotifier, GarageState>(
  (ref) => GarageNotifier(),
);
