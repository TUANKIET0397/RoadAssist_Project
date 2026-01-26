import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:road_assist/data/models/garage_model.dart';
import 'package:road_assist/ui/garage/account/viewmodel/garage_state.dart';

final garageProvider = StateNotifierProvider<GarageVM, GarageState>(
      (ref) => GarageVM(),
);

class GarageVM extends StateNotifier<GarageState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  GarageVM()
      : super(
    GarageState(
      savedGarage: GarageModel(
        id: '',
        name: '',
        phone: '',
        address: '',
        vehicleTypes: [],
        issues: [],
        openTime: '08:00',
        closeTime: '19:00',
        lat: 0.0,
        lng: 0.0,
        isActive: true,
        distance: 0.0,
      ),
      draftGarage: GarageModel(
        id: '',
        name: '',
        phone: '',
        address: '',
        vehicleTypes: [],
        issues: [],
        openTime: '08:00',
        closeTime: '19:00',
        lat: 0.0,
        lng: 0.0,
        isActive: true,
        distance: 0.0,
      ),
      workingDays: const [1, 2, 3, 4, 5],
      taxCode: '',
      isLoading: true,
    ),
  );

  Future<void> loadGarage(String garageId) async {
    state = state.copyWith(isLoading: true);

    try {

      final doc = await _firestore.collection('garages').doc(garageId).get();

      if (!doc.exists) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final data = doc.data()!;
      final garage = GarageModel.fromMap(doc.id, data);

      // Load workingDays và taxCode nếu có
      final workingDays = data['workingDays'] != null
          ? List<int>.from(data['workingDays'])
          : [1, 2, 3, 4, 5];
      final taxCode = data['taxCode'] as String?;

      state = state.copyWith(
        savedGarage: garage,
        draftGarage: garage, // Set draftGarage = savedGarage ban đầu
        workingDays: workingDays,
        taxCode: taxCode,
        isLoading: false,
      );

      debugPrint('Garage loaded successfully: ${garage.name}');
    } catch (e) {
      debugPrint('Error loading garage: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// 👇 THÊM: Load garage bằng userId (cho trường hợp garage login)
  Future<void> loadGarageByUserId(String userId) async {
    state = state.copyWith(isLoading: true);

    try {
      debugPrint('📥 Loading garage for user: $userId');

      // Tìm garage có userId này
      final query = await _firestore
          .collection('garages')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        debugPrint('No garage found for this user');
        state = state.copyWith(isLoading: false);
        return;
      }

      final doc = query.docs.first;
      final data = doc.data();
      final garage = GarageModel.fromMap(doc.id, data);

      final workingDays = data['workingDays'] != null
          ? List<int>.from(data['workingDays'])
          : [1, 2, 3, 4, 5];
      final taxCode = data['taxCode'] as String?;

      state = state.copyWith(
        savedGarage: garage,
        draftGarage: garage,
        workingDays: workingDays,
        taxCode: taxCode,
        isLoading: false,
      );

      debugPrint(' Garage loaded successfully: ${garage.name}');
    } catch (e) {
      debugPrint('Error loading garage: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// 👇 THÊM: Stream để realtime update
  Stream<GarageModel?> watchGarage(String garageId) {
    return _firestore.collection('garages').doc(garageId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return GarageModel.fromMap(doc.id, doc.data()!);
    });
  }

  /// ===== VEHICLE =====
  void toggleVehicle(String vehicle) {
    final vehicles = [...state.draftGarage.vehicleTypes];
    vehicles.contains(vehicle)
        ? vehicles.remove(vehicle)
        : vehicles.add(vehicle);

    state = state.copyWith(
      draftGarage: state.draftGarage.copyWith(vehicleTypes: vehicles),
    );
  }

  Future<void> addVehicleType({
    required String garageId,
    required String vehicleType,
  }) async {
    try {

      final currentVehicles = [...state.savedGarage.vehicleTypes];

      // Kiểm tra đã tồn tại chưa
      if (currentVehicles.contains(vehicleType)) {
        return;
      }

      currentVehicles.add(vehicleType);

      // Cập nhật vào Firestore
      await _firestore.collection('garages').doc(garageId).update({
        'vehicleTypes': currentVehicles,
      });

      // Cập nhật state local
      final updatedGarage = state.savedGarage.copyWith(
        vehicleTypes: currentVehicles,
      );

      state = state.copyWith(
        savedGarage: updatedGarage,
        draftGarage: updatedGarage,
      );

    } catch (e) {
      debugPrint(' Error adding vehicle type: $e');
      rethrow;
    }
  }

  Future<void> removeVehicleType({
    required String garageId,
    required String vehicleType,
  }) async {
    try {

      final currentVehicles = [...state.savedGarage.vehicleTypes];

      currentVehicles.remove(vehicleType);

      debugPrint('🔥 Updating Firestore...');
      await _firestore.collection('garages').doc(garageId).update({
        'vehicleTypes': currentVehicles,
      });
      debugPrint('🔥 Firestore updated successfully');

      // Cập nhật state local
      final updatedGarage = state.savedGarage.copyWith(
        vehicleTypes: currentVehicles,
      );

      state = state.copyWith(
        savedGarage: updatedGarage,
        draftGarage: updatedGarage,
      );

    } catch (e, stackTrace) {
      debugPrint(' Error removing vehicle type: $e');
      debugPrint(' Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// ===== SERVICE =====
  void toggleService(String service) {
    final services = [...state.draftGarage.issues];
    services.contains(service)
        ? services.remove(service)
        : services.add(service);

    state = state.copyWith(
      draftGarage: state.draftGarage.copyWith(issues: services),
    );
  }

  /// ===== WORKING DAYS =====
  void toggleWorkingDay(int day) {
    final days = [...state.workingDays];
    days.contains(day) ? days.remove(day) : days.add(day);
    state = state.copyWith(workingDays: days);
  }

  void setOpenTime(TimeOfDay time) {
    final newTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    state = state.copyWith(draftGarage: state.draftGarage.copyWith(openTime: newTime));
  }

  void setCloseTime(TimeOfDay time) {
    final newTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    state = state.copyWith(draftGarage: state.draftGarage.copyWith(closeTime: newTime));
  }

  /// ===== UPDATE DRAFT GARAGE =====
  void updateGarage(GarageModel garage) {
    state = state.copyWith(draftGarage: garage);
  }

  /// ===== UPDATE TAX CODE =====
  void updateTaxCode(String? taxCode) {
    state = state.copyWith(taxCode: taxCode);
  }

  /// ===== SAVE GARAGE =====
  Future<void> saveGarage({String? garageId, String? userId}) async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final garage = state.draftGarage;
      final garageData = garage.toMap();

      garageData['workingDays'] = state.workingDays;
      if (state.taxCode != null && state.taxCode!.isNotEmpty) {
        garageData['taxCode'] = state.taxCode;
      }

      String docId;
      if (garageId != null && garageId.isNotEmpty) {
        docId = garageId;
      } else if (userId != null && userId.isNotEmpty) {
        try {
          final query = await _firestore
              .collection('garages')
              .where('userId', isEqualTo: userId)
              .limit(1)
              .get();

          if (query.docs.isNotEmpty) {
            docId = query.docs.first.id;
          } else {
            docId = _firestore.collection('garages').doc().id;
            garageData['userId'] = userId;
          }
        } catch (e) {
          docId = _firestore.collection('garages').doc().id;
          garageData['userId'] = userId;
        }
      } else {
        docId = _firestore.collection('garages').doc().id;
      }

      await _firestore
          .collection('garages')
          .doc(docId)
          .set(garageData, SetOptions(merge: true));

      final savedDoc = await _firestore.collection('garages').doc(docId).get();
      final savedData = savedDoc.data()!;
      final savedGarage = GarageModel.fromMap(docId, savedData);

      final savedWorkingDays = savedData['workingDays'] != null
          ? List<int>.from(savedData['workingDays'])
          : state.workingDays;
      final savedTaxCode = savedData['taxCode'] as String?;

      state = state.copyWith(
        savedGarage: savedGarage,
        draftGarage: savedGarage, // 👈 Sync draftGarage với savedGarage
        workingDays: savedWorkingDays,
        taxCode: savedTaxCode,
        isLoading: false,
      );

    } catch (e, stackTrace) {

      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
