import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:road_assist/core/providers/auth_provider.dart';

final vehicleActionVMProvider = StateNotifierProvider<VehicleActionVM, bool>((
  ref,
) {
  return VehicleActionVM(ref);
});

class VehicleActionVM extends StateNotifier<bool> {
  final Ref ref;
  
  VehicleActionVM(this.ref) : super(false);

  Future<void> removeVehicle(String vehicleId) async {
    state = true;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('vehicles')
        .doc(vehicleId)
        .delete();

    // Invalidate providers để cập nhật UI ngay lập tức
    ref.invalidate(allUserVehiclesProvider);
    ref.invalidate(currentUserVehiclesProvider);
    ref.invalidate(currentUserVehiclesSubcollectionProvider);

    state = false;
  }

  Future<void> updateDescription(String vehicleId, String? description) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('vehicles')
        .doc(vehicleId)
        .update({
          'description': description?.trim().isEmpty ?? true
              ? null
              : description,
        });

    // Invalidate providers để cập nhật UI ngay lập tức
    ref.invalidate(allUserVehiclesProvider);
    ref.invalidate(currentUserVehiclesProvider);
    ref.invalidate(currentUserVehiclesSubcollectionProvider);
  }

  Future<void> addVehicle({
    required String type,
    String? description,
  }) async {
    state = true;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      state = false;
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('vehicles')
          .add({
        'type': type,
        'description': description?.trim().isEmpty ?? true ? null : description,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Invalidate providers để cập nhật UI ngay lập tức
      ref.invalidate(allUserVehiclesProvider);
      ref.invalidate(currentUserVehiclesProvider);
      ref.invalidate(currentUserVehiclesSubcollectionProvider);
    } catch (e) {
      print('❌ Error adding vehicle: $e');
    }

    state = false;
  }
}
