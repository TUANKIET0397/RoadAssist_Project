import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:road_assist/ui/garage/account/view/search_screen.dart';
import 'package:road_assist/ui/garage/account/viewmodel/garage_vm.dart';
import 'package:road_assist/ui/garage/account/widgets/action_button.dart';
import 'package:road_assist/ui/garage/account/widgets/vehicle_support_item.dart';
import 'package:road_assist/ui/garage/home/viewmodel/garage_home_viewmodel.dart' as vm;
import 'package:road_assist/ui/user/account/viewmodel/account_vm.dart';
import 'package:road_assist/ui/user/account/widgets/logout_button.dart';

import '../widgets/garage_card.dart';

class GarageAccountScreen extends ConsumerWidget {
  const GarageAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(garageProvider);
    final garage = state.savedGarage; // Dùng savedGarage cho hiển thị
    final colorScheme = Theme.of(context).colorScheme;
    // final vm = ref.read(accountVmProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trang Garage ',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.all(10),
            margin: EdgeInsets.only(right: 16, bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [
                  Color.fromRGBO(79, 172, 254, 1),
                  Color.fromRGBO(0, 242, 254, 1),
                ],
              ),
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ],
        backgroundColor: colorScheme.surface,
      ),
      body: Container(
        decoration: BoxDecoration(color: colorScheme.secondary),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              /// GARAGE INFO CARD
              GarageCard(garage: garage),

              const SizedBox(height: 18),

              /// VEHICLE SUPPORT
              const Text(
                'Loại Phương Tiện Hỗ trợ',
                style: TextStyle(
                  color: Color.fromRGBO(127, 199, 252, 1),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 18),

              ...garage.vehicleTypes.map(
                (vehicle) => VehicleSupportItem(
                  name: vehicle,
                  onAdd: () {
                    // TODO: handle add vehicle
                  },
                ),
              ),

              const SizedBox(height: 18),

              /// ACTIONS
              const Text(
                'Cứu hộ & hoạt động',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 18),

              Wrap(
                spacing: 16,
                runSpacing: 14,
                children: [
                  ActionButton(
                    icon: Icons.search,
                    label: 'Các cuộc cứu hộ',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },
                  ),
                  ActionButton(
                    icon: Icons.favorite,
                    label: 'Đánh Giá',
                    onTap: () {
                      context.go('/garage/review');
                    },
                  ),
                  ActionButton(
                    icon: Icons.info,
                    label: 'Thông tin Garage',
                    onTap: () {
                      context.push('/garage/account/info');
                    },
                  ),
                  ActionButton(
                    icon: Icons.lock,
                    label: 'Đổi mật khẩu',
                    onTap: () {
                      context.push('/garage/account/passwordreset');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 50),

              /// LOGOUT
              LogoutButton(onTap: vm.logout),
              LogoutButton(onTap: vm.logout),
            ],
          ),
        ),
      ),
    );
  }
}
