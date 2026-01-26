import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:road_assist/data/models/garage_model.dart';
import 'package:road_assist/ui/garage/account/viewmodel/garage_state.dart';

///
final garageProvider =
StateNotifierProvider.family<GarageVM, GarageState, String>(
      (ref, userId) => GarageVM(userId),
);

/// VIEW MODEL
class GarageVM extends StateNotifier<GarageState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;
  StreamSubscription<QuerySnapshot>? _garageSubscription;

  GarageVM(this.userId)
      : super(
    GarageState(
      savedGarage: GarageModel.initial(),
      draftGarage: GarageModel.initial(),
      workingDays: const [1, 2, 3, 4, 5],
      taxCode: '',
      isLoading: true,
    ),
  ) {
    _listenToGarage();
  }

  void _listenToGarage() {
    if (userId.isEmpty) {
      state = state.copyWith(isLoading: false);
      return;
    }

    _garageSubscription = _firestore
        .collection('garages')
        .where('id', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .listen(
          (snapshot) {
        if (snapshot.docs.isEmpty) {
          state = state.copyWith(isLoading: false);
          return;
        }

        final doc = snapshot.docs.first;
        final data = doc.data();
        final garage = GarageModel.fromMap(doc.id, data);

        state = state.copyWith(
          savedGarage: garage,
          draftGarage: garage,
          workingDays: data['operatingDays'] != null
              ? List<int>.from(data['operatingDays'])
              : const [1, 2, 3, 4, 5],
          taxCode: data['taxCode'] as String?,
          isLoading: false,
        );
      },
      onError: (_) {
        state = state.copyWith(isLoading: false);
      },
    );
  }


  Future<void> addVehicleType({
    required String garageId,
    required String vehicleType,
  }) async {
    final vehicles = [...state.savedGarage.vehicleTypes];
    if (vehicles.contains(vehicleType)) return;

    vehicles.add(vehicleType);

    await _firestore.collection('garages').doc(garageId).update({
      'vehicleTypes': vehicles,
    });
  }

  Future<void> removeVehicleType({
    required String garageId,
    required String vehicleType,
  }) async {
    final vehicles = [...state.savedGarage.vehicleTypes]
      ..remove(vehicleType);

    await _firestore.collection('garages').doc(garageId).update({
      'vehicleTypes': vehicles,
    });
  }

  void toggleWorkingDay(int day) {
    final days = [...state.workingDays];
    days.contains(day) ? days.remove(day) : days.add(day);
    state = state.copyWith(workingDays: days);
  }


  void setOpenTime(TimeOfDay time) {
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    state = state.copyWith(
      draftGarage: state.draftGarage.copyWith(openTime: timeStr),
    );
  }

  void setCloseTime(TimeOfDay time) {
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    state = state.copyWith(
      draftGarage: state.draftGarage.copyWith(closeTime: timeStr),
    );
  }

  /// UPDATE
  void updateGarage(GarageModel garage) {
    state = state.copyWith(draftGarage: garage);
  }

  void updateTaxCode(String? taxCode) {
    state = state.copyWith(taxCode: taxCode);
  }

  /// SAVE GARAGE
  Future<void> saveGarage() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final garage = state.draftGarage;

      final data = garage.toMap()
        ..['id'] = userId
        ..['operatingDays'] = state.workingDays;

      if (state.taxCode?.isNotEmpty == true) {
        data['taxCode'] = state.taxCode;
      }

      final docId =
      garage.id.isNotEmpty ? garage.id : userId;

      await _firestore
          .collection('garages')
          .doc(docId)
          .set(data, SetOptions(merge: true));

      state = state.copyWith(isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }


  void toggleService(String service) {
    final services = [...state.draftGarage.issues];

    services.contains(service)
        ? services.remove(service)
        : services.add(service);

    state = state.copyWith(
      draftGarage: state.draftGarage.copyWith(issues: services),
    );
  }

  /// MANUAL REFRESH
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);

    try {
      final query = await _firestore
          .collection('garages')
          .where('id', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final doc = query.docs.first;
      final data = doc.data();
      final garage = GarageModel.fromMap(doc.id, data);

      state = state.copyWith(
        savedGarage: garage,
        draftGarage: garage,
        workingDays: data['operatingDays'] != null
            ? List<int>.from(data['operatingDays'])
            : const [1, 2, 3, 4, 5],
        taxCode: data['taxCode'] as String?,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// DISPOSE
  @override
  void dispose() {
    _garageSubscription?.cancel();
    super.dispose();
  }
}
