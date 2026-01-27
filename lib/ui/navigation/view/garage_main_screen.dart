import 'package:flutter/material.dart';
import 'package:road_assist/ui/call/screens/incoming_call_screen.dart';
import 'package:road_assist/ui/navigation/configs/garage_bottom_nav.dart';
import 'package:road_assist/ui/navigation/widgets/slanted_animated_bottom_bar.dart';

class GarageMainScreen extends StatelessWidget {
  final Widget child;

  const GarageMainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return IncomingCallListener(
      homeScreen: Scaffold(
        extendBody: true,
        body: child,
        bottomNavigationBar: SlantedAnimatedBottomBar(
          items: garageBottomNavItems,
          defaultIndex: 2,
        ),
      ),
    );
  }

  // Removed: Call initiation moved to chat screen only
}
