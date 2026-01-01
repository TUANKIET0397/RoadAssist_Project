import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:road_assist/data/models/response/garage_model.dart';

class GarageViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  List<GarageModel> _garages = [];

  bool get isLoading => _isLoading;

  List<GarageModel> get garages => _garages;

  /// Tải list garage
  Future<void> fetchGarages() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('garages')
          .where('isActive', isEqualTo: true)
          .get();

      _garages = snapshot.docs
          .map(
            (doc) =>
            GarageModel.fromMap(
              doc.id,
              doc.data(),
            ),
      )
          .toList();
    } catch (e) {
      debugPrint('❌ Lỗi load garages: $e');
    }

    _isLoading = false;
    notifyListeners();
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

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Lỗi toggle favorite: $e');
    }
  }
}
