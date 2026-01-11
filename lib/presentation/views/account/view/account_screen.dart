import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/presentation/views/account/viewmodel/account_vm.dart';
import 'package:road_assist/presentation/views/account/widgets/action_grid.dart';
import 'package:road_assist/presentation/views/account/widgets/logout_button.dart';
import 'package:road_assist/presentation/views/account/widgets/profile_card.dart';
import 'package:road_assist/presentation/views/account/widgets/vehicle_section.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

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
        actions: [
          Container(
            padding: const EdgeInsets.all(10),
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
              ),
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ],
        backgroundColor: const Color.fromRGBO(37, 44, 59, 1),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
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
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: VehicleSection(
                vehicles: state.vehicles,
                onChangeN: vm.changeName,
                onRemove: vm.removeVehicle,
              ),
            ),
            const SizedBox(height: 10),

            ActionGrid(actions: vm.actions, onTap: vm.onActionTap),

            const SizedBox(height: 24),
            LogoutButton(onTap: vm.logout),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
