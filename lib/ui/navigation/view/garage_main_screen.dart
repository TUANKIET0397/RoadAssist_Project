import 'package:flutter/material.dart';
import 'package:road_assist/ui/navigation/configs/garage_bottom_nav.dart';
import 'package:road_assist/ui/navigation/widgets/slanted_animated_bottom_bar.dart';

class GarageMainScreen extends StatelessWidget {
  final Widget child;

  const GarageMainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: SlantedAnimatedBottomBar(
        items: garageBottomNavItems,
        defaultIndex: 2,
      ),
    );
  }
}
