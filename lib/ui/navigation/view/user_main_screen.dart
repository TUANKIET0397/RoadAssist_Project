import 'package:flutter/material.dart';
import 'package:road_assist/ui/call/screens/call_screen.dart';
import 'package:road_assist/ui/navigation/configs/user_bottom_nav.dart';
import 'package:road_assist/ui/navigation/widgets/slanted_animated_bottom_bar.dart';

class UserMainScreen extends StatelessWidget {
  final Widget child;

  const UserMainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: SlantedAnimatedBottomBar(
        items: userBottomNavItems,
        defaultIndex: 2,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Text('Gọi'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CallScreen(callId: 'call_001', isCaller: true),
              // const CallScreen(callId: 'call_001', isCaller: false),
            ),
          );
        },
      ),
    );
  }
}
