import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/garage/account/viewmodel/garage_vm.dart';

class ServicesSelector extends ConsumerWidget {
  final List<String> selected;

  const ServicesSelector({super.key, required this.selected});

  static const allServices = [
    'Hết xăng',
    'Bể lốp',
    'Mất chìa khóa',
    'Hư máy',
    'Vận chuyển xe',
    'Xẹp lốp',
    'Khác',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(garageProvider);
    final garage = state.draftGarage; // Dùng draftGarage cho form
    final currentServices = garage.issues; // Dùng issues thay vì services

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dịch vụ hỗ trợ',
          style: TextStyle(
            color: Color.fromRGBO(127, 199, 252, 1),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allServices.map((s) {
            final isSelected = currentServices.contains(s);
            return FilterChip(
              label: Text(s),
              selected: isSelected,
              onSelected: (selected) {
                ref.read(garageProvider.notifier).toggleService(s);
              },
              selectedColor: Colors.blue.withOpacity(0.3),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
