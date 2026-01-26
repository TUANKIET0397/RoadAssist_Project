// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:road_assist/core/providers/auth_provider.dart';
// import 'package:road_assist/ui/garage/account/viewmodel/garage_vm.dart';
//
// class ServiceSupportSection extends ConsumerWidget {
//   const ServiceSupportSection({super.key});
//
//   static const services = [
//     'Hết xăng',
//     'Bể lốp',
//     'Mất chìa khóa',
//     'Hư máy',
//     'Vận chuyển xe',
//     'Khác',
//   ];
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final userId = ref.watch(userIdProvider);
//     if (userId == null) {
//       return const Scaffold(
//         body: Center(child: Text('Chưa đăng nhập')),
//       );
//     }
//
//     final state = ref.watch(garageProvider(userId));
//     final garage = state.draftGarage; // Dùng draftGarage cho form
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Dịch vụ hỗ trợ',
//           style: TextStyle(
//             color: Color.fromRGBO(127, 199, 252, 1),
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Wrap(
//           spacing: 8,
//           children: services.map((service) {
//             final selected = garage.issues.contains(
//               service,
//             ); // Dùng issues thay vì services
//             return FilterChip(
//               label: Text(service),
//               selected: selected,
//               onSelected: (_) {
//                 ref.read(garageProvider(userId).notifier).toggleService(service);
//               },
//             );
//           }).toList(),
//         ),
//         const SizedBox(height: 32),
//       ],
//     );
//   }
// }
