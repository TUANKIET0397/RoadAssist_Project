import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final vehicleActionVMProvider = StateNotifierProvider<VehicleActionVM, bool>((
  ref,
) {
  return VehicleActionVM();
});

class VehicleActionVM extends StateNotifier<bool> {
  VehicleActionVM() : super(false);

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
  }
}
