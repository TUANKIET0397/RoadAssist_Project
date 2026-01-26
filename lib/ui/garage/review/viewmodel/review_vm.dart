import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:road_assist/data/models/review_model.dart';

class GarageReviewState {
  final bool isLoading;
  final List<ReviewModel> reviews;

  GarageReviewState({
    this.isLoading = false,
    this.reviews = const [],
  });

  GarageReviewState copyWith({
    bool? isLoading,
    List<ReviewModel>? reviews,
  }) {
    return GarageReviewState(
      isLoading: isLoading ?? this.isLoading,
      reviews: reviews ?? this.reviews,
    );
  }
}

class GarageReviewNotifier extends StateNotifier<GarageReviewState> {
  GarageReviewNotifier() : super(GarageReviewState());

  final _firestore = FirebaseFirestore.instance;
  StreamSubscription? _subscription;

  void watchReviews(String garageId) {
    state = state.copyWith(isLoading: true);

    _subscription?.cancel();

    _subscription = _firestore
        .collection('garages')
        .doc(garageId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
        final reviews = snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.data()))
            .toList();

        state = state.copyWith(
          reviews: reviews,
          isLoading: false,
        );
      },
      onError: (e) {
        debugPrint('Watch reviews error: $e');
        state = state.copyWith(isLoading: false);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final garageReviewProvider =
StateNotifierProvider<GarageReviewNotifier, GarageReviewState>(
      (ref) => GarageReviewNotifier(),
);
