import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/account_garage/viewmodel/garage_vm.dart';

class ServiceSupportSection extends ConsumerWidget {
  const ServiceSupportSection({super.key});

  static const services = [
    'Hết xăng',
    'Bể lốp',
    'Mất chìa khóa',
    'Hư máy',
    'Vận chuyển xe',
    'Khác',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(garageProvider);
    final garage = state.draftGarage; // Dùng draftGarage cho form

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
          children: services.map((service) {
            final selected = garage.issues.contains(service); // Dùng issues thay vì services
            return FilterChip(
              label: Text(service),
              selected: selected,
              onSelected: (_) {
                ref.read(garageProvider.notifier).toggleService(service);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
