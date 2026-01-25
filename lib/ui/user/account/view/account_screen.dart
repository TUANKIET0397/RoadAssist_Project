import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/garage/home/viewmodel/garage_home_viewmodel.dart'
    as vm;
import 'package:road_assist/ui/user/account/viewmodel/account_vm.dart';
import 'package:road_assist/ui/user/account/widgets/action_grid.dart';
import 'package:road_assist/ui/user/account/widgets/logout_button.dart';
import 'package:road_assist/ui/user/account/widgets/profile_card.dart';
import 'package:road_assist/ui/user/account/widgets/vehicle_section.dart';

import '../model/vehicle_model.dart';

const List<String> kUserVehicleTypes = [
  'Xe máy',
  'Xe Bốn bánh',
  'Ô tô',
  'Xe tải',
];

const Map<String, String> kVehicleImages = {
  'Xe máy': 'assets/images/illustrations/motorbike.png',
  'Xe Bốn bánh': 'assets/images/illustrations/car4.png',
  'Ô tô': 'assets/images/illustrations/car.png',
  'Xe tải': 'assets/images/illustrations/truck.png',
};

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(accountStreamProvider);

    return userAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Có lỗi xảy ra: $e')),
      data: (user) {
        if (user == null) {
          return const Center(child: Text('Đang tải thông tin người dùng...'));
        }

        final vehicles = user.vehicles;

        //         final vehicles = (user.vehicles ?? [])
        // .map((e) => Vehicle.fromMap(e))
        // .toList();
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Trang cá nhân',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color.fromRGBO(37, 44, 59, 1),
          ),
          body: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0E1A2B), Color(0xFF2E3CBF)],
              ),
            ),
            child: ListView(
              clipBehavior: Clip.none,
              children: [
                ProfileCard(user: user),
                const SizedBox(height: 20),

                const Text(
                  'Phương tiện của tôi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                VehicleSection(
                  vehicles: vehicles,
                  onEdit: (vehicle) =>
                      _openEditBottomSheet(context, ref, vehicle),
                  onRemove: (vehicle) =>
                      _removeVehicleFromFirebase(ref, vehicle),
                  onAdd: () =>
                      _openAddVehicleBottomSheet(context, ref, vehicles),
                ),

                // const SizedBox(height: 20),
                // ActionGrid(actions: vm.actions, onTap: vm.onActionTap),
                const SizedBox(height: 24),
                LogoutButton(onTap: vm.logout),
              ],
            ),
          ),
        );

        // return
        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Text('Tên: ${user.name}'),
        //     Text('SĐT: ${user.phone}'),
        //     Text('Địa chỉ: ${user.address}'),
        //     Text('Loại xe: ${user.vehicleTypes.join(', ')}'),
        //   ],
        // );
      },
    );
  }

  Future<void> _removeVehicleFromFirebase(
    WidgetRef ref,
    Vehicle vehicle,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'vehicles': FieldValue.arrayRemove([vehicle.toMap()]),
    }, SetOptions(merge: true));
  }

  void _openEditBottomSheet(
    BuildContext context,
    WidgetRef ref,
    Vehicle vehicle,
  ) {
    final controller = TextEditingController(text: vehicle.description ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mô tả cho ${vehicle.type}'),
              TextField(controller: controller),
              ElevatedButton(
                onPressed: () async {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid == null) return;

                  final doc = FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid);

                  // remove old
                  await doc.set({
                    'vehicles': FieldValue.arrayRemove([vehicle.toMap()]),
                  }, SetOptions(merge: true));

                  // add new
                  await doc.set({
                    'vehicles': FieldValue.arrayUnion([
                      vehicle
                          .copyWith(
                            description: controller.text.trim().isEmpty
                                ? null
                                : controller.text.trim(),
                          )
                          .toMap(),
                    ]),
                  }, SetOptions(merge: true));

                  Navigator.pop(context);
                },
                child: const Text('Lưu'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openAddVehicleBottomSheet(
    BuildContext context,
    WidgetRef ref,
    List<Vehicle> currentVehicles,
  ) {
    String? selectedType;
    final descController = TextEditingController();
    final existingTypes = currentVehicles.map((v) => v.type).toSet();

    final availableTypes = kUserVehicleTypes
        .where((type) => !existingTypes.contains(type))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromRGBO(25, 37, 59, 1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        if (availableTypes.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Bạn đã thêm đầy đủ các loại phương tiện',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thêm phương tiện',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  /// TYPE
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    items: availableTypes
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedType = v),
                    decoration: const InputDecoration(
                      hintText: 'Chọn loại phương tiện',
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// DESCRIPTION
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Mô tả phương tiện (tuỳ chọn)',
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedType == null
                          ? null
                          : () async {
                              final uid =
                                  FirebaseAuth.instance.currentUser?.uid;
                              if (uid == null) return;

                              final vehicle = Vehicle(
                                type: selectedType!,
                                description: descController.text.trim().isEmpty
                                    ? null
                                    : descController.text.trim(),
                              );

                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .set({
                                    'vehicles': FieldValue.arrayUnion([
                                      vehicle.toMap(),
                                    ]),
                                  }, SetOptions(merge: true));

                              Navigator.pop(context);
                            },
                      child: const Text('Thêm phương tiện'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
