import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/presentation/views/account/view/account_screen.dart';
import 'package:road_assist/presentation/views/chat/view/chat_screen.dart';
import 'package:road_assist/presentation/views/garage/view/garage_screen.dart';
import 'package:road_assist/presentation/views/history/view/history_screen.dart';
import 'package:road_assist/presentation/views/home/view/home_screen.dart';
import 'package:road_assist/presentation/views/navigation/view/slanted_bottom_bar.dart';
import 'package:road_assist/presentation/views/navigation/viewmodel/navigation_viewmodel.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navigationProvider);

    final pages = const [
      ChatScreen(),
      GarageScreen(),
      HomeScreen(),
      HistoryScreen(),
      AccountScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: pages[index],
      bottomNavigationBar: const SlantedAnimatedBottomBar(),
    );
  }
}
