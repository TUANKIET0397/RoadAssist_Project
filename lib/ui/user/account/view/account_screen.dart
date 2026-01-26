import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:road_assist/data/datasources/local/vehicle_constants.dart';
import 'package:road_assist/ui/garage/home/viewmodel/garage_home_viewmodel.dart'
    as outViewModel;

import 'package:road_assist/ui/user/account/viewmodel/account_vm.dart';
import 'package:road_assist/ui/user/account/widgets/action_grid.dart';
import 'package:road_assist/ui/user/account/widgets/action_item.dart';
import 'package:road_assist/ui/user/account/widgets/logout_button.dart';
import 'package:road_assist/ui/user/account/widgets/profile_card.dart';
import 'package:road_assist/ui/user/account/widgets/vehicle_section.dart';

import '../model/vehicle_model.dart';

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
                      _removeVehicleFromFirebase(context, ref, vehicle),
                  onAdd: () =>
                      _openAddVehicleBottomSheet(context, ref, vehicles),
                ),

                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cứu hộ & hoạt động',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    //dùng lại với garage
                    ActionGrid(
                      children: [
                        ActionItem(
                          title: 'Các cuộc cứu hộ',
                          icon: Icons.search,
                          onTap: () {
                            // đi tới rescue
                          },
                        ),
                        ActionItem(
                          title: 'Garage yêu thích',
                          icon: Icons.favorite_border,
                          onTap: () {
                            context.push('/user/garage/favourite');
                          },
                        ),
                        ActionItem(
                          title: 'Thông tin cá nhân',
                          icon: Icons.person_outline,
                          onTap: () {
                            context.push('/user/account/changeInfo');
                          },
                        ),
                        ActionItem(
                          title: 'Đổi mật khẩu',
                          icon: Icons.lock_outline,
                          onTap: () {
                            context.push('/user/account/resetPassword');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                LogoutButton(onTap: outViewModel.logout),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _removeVehicleFromFirebase(
      BuildContext context,
      WidgetRef ref,
      Vehicle vehicle,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A38),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: Color(0xFF4FC3F7),
            width: 2,
          ),
        ),
        title: const Text(
          'Xác nhận xóa',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Bạn có chắc muốn xóa phương tiện này?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Hủy',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(
      {
        'vehicles': FieldValue.arrayRemove([vehicle.toMap()]),
      },
      SetOptions(merge: true),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa phương tiện'),
          backgroundColor: Colors.green,
        ),
      );
    }
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
