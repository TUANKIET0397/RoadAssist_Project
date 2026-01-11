import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/presentation/views/account/view/account_screen.dart';
import 'package:road_assist/presentation/views/chat/view/chatList_screen.dart';
import 'package:road_assist/presentation/views/garage/view/garage_screen.dart';
<<<<<<< HEAD
import 'package:road_assist/presentation/views/history/view/history_screen.dart';
=======
import 'package:road_assist/presentation/views/garage/view/garageDetail.dart';
import 'package:road_assist/presentation/views/navigation/viewmodel/garage_navigation_provider.dart';
>>>>>>> 0c090f0001d9b6aa41c7043f70947c8dc6aaa7c4
import 'package:road_assist/presentation/views/home/view/home_screen.dart';
import 'package:road_assist/presentation/views/navigation/view/slanted_bottom_bar.dart';
import 'package:road_assist/presentation/views/navigation/viewmodel/navigation_viewmodel.dart';

import 'package:road_assist/core/providers/auth_provider.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Index = ref.watch(navigationProvider);
    final selectedGarage = ref.watch(selectedGarageProvider);
    final userId = ref.watch(userIdProvider);

    Widget buildGaragePage() {
      if (selectedGarage == null) {
        return const GarageListScreen();
      } else {
        return GarageDetailScreen(garage: selectedGarage);
      }
    }

    final pages = [
      if (userId != null) ChatListScreen(userId: userId) else const SizedBox(),
      buildGaragePage(),
      const HomeScreen(),
      const HistoryScreen(),
      const AccountScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: pages[Index],
      bottomNavigationBar: const SlantedAnimatedBottomBar(),
    );
  }
}
