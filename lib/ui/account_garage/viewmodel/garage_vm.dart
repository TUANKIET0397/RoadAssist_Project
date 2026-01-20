import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:road_assist/data/models/garage_model.dart';
import 'package:road_assist/ui/account_garage/viewmodel/garage_state.dart';

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
            name: 'Minh Thuận Garage',
            phone: '0337760280',
            address: '15B Nguyễn Lương Bằng, Quận 7',
            vehicleTypes: ['Xe máy', 'Ô tô'],
            issues: ['Hết xăng', 'Bể lốp'],
            openTime: '08:00',
            closeTime: '19:00',
            lat: 0.0,
            lng: 0.0,
            isActive: true,
            distance: 0.0,
          ),
          draftGarage: GarageModel(
            id: '',
            name: 'Minh Thuận Garage',
            phone: '0337760280',
            address: '15B Nguyễn Lương Bằng, Quận 7',
            vehicleTypes: ['Xe máy', 'Ô tô'],
            issues: ['Hết xăng', 'Bể lốp'],
            openTime: '08:00',
            closeTime: '19:00',
            lat: 0.0,
            lng: 0.0,
            isActive: true,
            distance: 0.0,
          ),
          workingDays: const [1, 2, 3, 4, 5],
          taxCode: '0113214239',
        ),
      );

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
      debugPrint('Save already in progress, skipping...');
      return;
    }

    // Set loading state
    state = state.copyWith(isLoading: true);

    try {
      final garage = state.draftGarage;

      // Convert GarageModel to Firestore format using toMap()
      final garageData = garage.toMap();

      // Add workingDays và taxCode (không có trong GarageModel)
      garageData['workingDays'] = state.workingDays;
      if (state.taxCode != null && state.taxCode!.isNotEmpty) {
        garageData['taxCode'] = state.taxCode;
      }

      // Determine document ID
      String docId;
      if (garageId != null && garageId.isNotEmpty) {
        docId = garageId;
      } else if (userId != null && userId.isNotEmpty) {
        // Try to find existing garage by userId first
        try {
          final query = await _firestore
              .collection('garages')
              .where('userId', isEqualTo: userId)
              .limit(1)
              .get();

          if (query.docs.isNotEmpty) {
            docId = query.docs.first.id;
          } else {
            // Create new garage document with userId as reference
            docId = _firestore.collection('garages').doc().id;
            garageData['userId'] = userId;
          }
        } catch (e) {
          // If query fails, create new garage
          debugPrint('Query failed, creating new garage: $e');
          docId = _firestore.collection('garages').doc().id;
          garageData['userId'] = userId;
        }
      } else {
        // Create new garage
        docId = _firestore.collection('garages').doc().id;
      }

      // Save/update to Firestore
      await _firestore
          .collection('garages')
          .doc(docId)
          .set(garageData, SetOptions(merge: true));

      // Load lại garage từ Firestore để có đầy đủ thông tin (bao gồm id)
      final savedDoc = await _firestore.collection('garages').doc(docId).get();
      final savedData = savedDoc.data()!;
      final savedGarage = GarageModel.fromMap(docId, savedData);

      // Load lại workingDays và taxCode từ Firestore nếu có
      final savedWorkingDays = savedData['workingDays'] != null
          ? List<int>.from(savedData['workingDays'])
          : state.workingDays;
      final savedTaxCode = savedData['taxCode'] as String?;

      // Only update savedGarage after successful save
      state = state.copyWith(
        savedGarage: savedGarage,
        workingDays: savedWorkingDays,
        taxCode: savedTaxCode,
        isLoading: false,
      );

      debugPrint('Garage saved successfully with ID: $docId');
    } catch (e, stackTrace) {
      debugPrint('❌ Lỗi lưu garage: $e');
      debugPrint('📋 Stack trace: $stackTrace');

      // Log chi tiết lỗi để debug
      if (e.toString().contains('permission')) {
        debugPrint('⚠️ Lỗi quyền truy cập! Kiểm tra Firestore Rules.');
      } else if (e.toString().contains('network')) {
        debugPrint('⚠️ Lỗi mạng! Kiểm tra internet connection.');
      } else if (e.toString().contains('not-found')) {
        debugPrint('⚠️ Collection không tồn tại! Sẽ tự động tạo khi lưu.');
      }

      rethrow; // Re-throw để button có thể hiển thị error message
    } finally {
      // Đảm bảo loading state luôn được reset, bất kể có lỗi hay không
      state = state.copyWith(isLoading: false);
      debugPrint('✅ Loading state đã được reset');
    }
  }
}
