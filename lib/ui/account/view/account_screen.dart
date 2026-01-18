import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:road_assist/ui/account/model/vehicle_model.dart';
import 'package:road_assist/ui/account/viewmodel/account_vm.dart';

import 'package:road_assist/ui/account/widgets/action_grid.dart';
import 'package:road_assist/ui/account/widgets/edit_vehicle_dialog.dart';
import 'package:road_assist/ui/account/widgets/logout_button.dart';
import 'package:road_assist/ui/account/widgets/profile_card.dart';
import 'package:road_assist/ui/account/widgets/vehicle_section.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  void _openEditBottomSheet(
    BuildContext context,
    WidgetRef ref,
    Vehicle vehicle,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromRGBO(25, 37, 59, 1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EditVehicleBottomSheet(
        vehicle: vehicle,
        onSubmit: (value) {
          ref
              .read(accountVmProvider.notifier)
              .updateVehicleDescription(vehicle, value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountVmProvider);
    final vm = ref.read(accountVmProvider.notifier);

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
            ProfileCard(user: state.user),
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
              vehicles: state.vehicles,
              onEdit: (vehicle) => _openEditBottomSheet(context, ref, vehicle),
              onRemove: vm.removeVehicle,
            ),

            const SizedBox(height: 20),
            ActionGrid(actions: vm.actions, onTap: vm.onActionTap),
            const SizedBox(height: 24),
            LogoutButton(onTap: vm.logout),
          ],
        ),
      ),
    );
  }
}
