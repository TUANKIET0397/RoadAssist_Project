import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/acount_garage/viewmodel/garage_provider.dart';
import 'package:road_assist/ui/acount_garage/widgets/action_button.dart';
import 'package:road_assist/ui/acount_garage/widgets/vehicle_support_item.dart';

import '../widgets/garage_card.dart';

class GarageScreen extends ConsumerWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garage = ref.watch(garageProvider);
    final colorScheme = Theme.of(context).colorScheme;

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
        actions: [Icon(Icons.add)],
        backgroundColor: colorScheme.surface,
      ),
      backgroundColor: colorScheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     const Text(
              //       'Trang Garage',
              //       style: TextStyle(
              //         color: Colors.white,
              //         fontSize: 22,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //     const CircleAvatar(
              //       backgroundColor: Colors.blueAccent,
              //       child: Icon(Icons.person, color: Colors.white),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 20),

              /// GARAGE INFO CARD
              GarageCard(garage: garage),

              const SizedBox(height: 24),

              /// VEHICLE SUPPORT
              const Text(
                'Loại Phương Tiện Hỗ trợ',
                style: TextStyle(
                  color: Colors.lightBlueAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              ...garage.supportedVehicles.map(
                (vehicle) => VehicleSupportItem(
                  name: vehicle,
                  onAdd: () {
                    // TODO: handle add vehicle
                  },
                ),
              ),

              const SizedBox(height: 32),

              /// ACTIONS
              const Text(
                'Cứu hộ & hoạt động',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: const [
                  ActionButton(icon: Icons.search, label: 'Các cuộc cứu hộ'),
                  ActionButton(icon: Icons.favorite, label: 'Đánh Giá'),
                  ActionButton(icon: Icons.info, label: 'Thông tin Garage'),
                  ActionButton(icon: Icons.lock, label: 'Đổi mật khẩu'),
                ],
              ),

              const SizedBox(height: 40),

              /// LOGOUT
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Firebase logout
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Đăng Xuất'),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Đổi thành User',
                      style: TextStyle(
                        color: Colors.white70,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
