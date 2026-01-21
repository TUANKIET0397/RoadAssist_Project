import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:road_assist/data/models/garage_model.dart';
import 'package:road_assist/ui/auth/viewmodel/garage_success_vm.dart';
import 'package:road_assist/ui/auth/widgets/success_header.dart';
import 'package:road_assist/ui/auth/widgets/garage_info_card.dart';

class GarageSuccessView extends ConsumerWidget {
  final GarageModel garage;

  const GarageSuccessView({super.key, required this.garage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vmProvider = garageSuccessVMProvider(garage);
    final state = ref.watch(vmProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trang chủ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF202A44), Color(0xFF334268)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Success Header with animation
                const SuccessHeader(),

                const SizedBox(height: 32),

                // Garage Info Card
                GarageInfoCard(
                  garage: state.garage,
                  openStatus: state.openStatus,
                  openHours: state.openHours,
                ),

                const SizedBox(height: 24),

                // Vehicle Types Section
                ...state.garage.vehicleTypes.map((type) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF000718),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF37B6E9),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Loại phương tiện',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        Text(
                          type,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF508DBC),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 24),

                // Home Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            // TODO: Navigate to Garage's Homepage
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007DFA),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                      shadowColor: const Color(0xFF00BFFC).withOpacity(0.5),
                    ),
                    child: state.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Về Trang chủ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Update Info Button (Optional)
                Center(
                  child: TextButton(
                    onPressed: () {
                      //TODO: Navigate to Update Garage Info Screen
                    },
                    child: Text(
                      'Cập nhật thông tin Garage',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF53789A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
