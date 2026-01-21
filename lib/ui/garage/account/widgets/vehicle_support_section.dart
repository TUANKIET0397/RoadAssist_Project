import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/garage/account/viewmodel/garage_vm.dart';

class VehicleSupportSection extends ConsumerWidget {
  const VehicleSupportSection({super.key});

  static const allVehicles = ['Xe máy', 'Ô tô', 'Xe tải'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(garageProvider);
    final garage = state.draftGarage; // Dùng draftGarage cho form

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Loại phương tiện hỗ trợ',
          style: TextStyle(
            color: Color.fromRGBO(127, 199, 252, 1),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: allVehicles.map((vehicle) {
            final selected = garage.vehicleTypes.contains(
              vehicle,
            ); // Dùng vehicleTypes
            return FilterChip(
              label: Text(vehicle),
              selected: selected,
              onSelected: (_) {
                ref.read(garageProvider.notifier).toggleVehicle(vehicle);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
