import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/garage/account/view/favorite_screen.dart';
import 'package:road_assist/ui/garage/account/view/info_screen.dart';
import 'package:road_assist/ui/garage/account/view/password_reset_sreen.dart';
import 'package:road_assist/ui/garage/account/view/search_screen.dart';
import 'package:road_assist/ui/garage/account/viewmodel/garage_vm.dart';
import 'package:road_assist/ui/garage/account/widgets/action_button.dart';
import 'package:road_assist/ui/garage/account/widgets/vehicle_support_item.dart';

import '../widgets/garage_card.dart';

class GarageScreen extends ConsumerWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(garageProvider);
    final garage = state.savedGarage; // Dùng savedGarage cho hiển thị
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
      body: SafeArea(
        child: Container(
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FavoriteScreen(),
                          ),
                        );
                      },
                    ),
                    ActionButton(
                      icon: Icons.info,
                      label: 'Thông tin Garage',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InfoScreen(),
                          ),
                        );
                      },
                    ),
                    ActionButton(
                      icon: Icons.lock,
                      label: 'Đổi mật khẩu',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PasswordResetSreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                /// LOGOUT
                Center(
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Firebase logout
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(75, 76, 237, 1),
                          shadowColor: const Color.fromRGBO(55, 182, 233, 1),
                          elevation: 8,

                          padding: const EdgeInsets.symmetric(
                            horizontal: 80,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Đăng Xuất',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
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
      ),
    );
  }
}
