// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:road_assist/core/providers/auth_provider.dart';
// import 'package:road_assist/ui/user/account/view/account_screen.dart';
// import 'package:road_assist/ui/user/chat/view/chatList_screen.dart';
// import 'package:road_assist/ui/user/garage/view/garageDetail.dart';
// import 'package:road_assist/ui/user/garage/view/garage_screen.dart';
// import 'package:road_assist/ui/user/history/view/history_screen.dart';
// import 'package:road_assist/ui/user/home/view/home_screen.dart';
// import 'package:road_assist/ui/navigation/widgets/slanted_bottom_bar.dart';
// import 'package:road_assist/ui/navigation/viewmodel/garage_navigation_provider.dart';
// import 'package:road_assist/ui/navigation/viewmodel/navigation_viewmodel.dart';

// class MainScreen extends ConsumerWidget {
//   const MainScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final Index = ref.watch(navigationProvider);
//     final selectedGarage = ref.watch(selectedGarageProvider);
//     final userId = ref.watch(userIdProvider);

//     Widget buildGaragePage() {
//       if (selectedGarage == null) {
//         return const GarageListScreen();
//       } else {
//         return GarageDetailScreen(garage: selectedGarage);
//       }
//     }

//     final pages = [
//       if (userId != null) ChatListScreen() else const SizedBox(),
//       buildGaragePage(),
//       const HomeScreen(),
//       const HistoryScreen(),
//       const AccountScreen(),
//     ];

//     return Scaffold(
//       extendBody: true,
//       body: pages[Index],
//       bottomNavigationBar: const SlantedAnimatedBottomBar(),
//     );
//   }
// }
