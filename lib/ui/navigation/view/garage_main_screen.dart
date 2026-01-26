// import 'package:flutter/material.dart';
// import 'package:road_assist/ui/navigation/configs/garage_bottom_nav.dart';
// import 'package:road_assist/ui/navigation/widgets/slanted_animated_bottom_bar.dart';

// class GarageMainScreen extends StatelessWidget {
//   final Widget child;

//   const GarageMainScreen({super.key, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBody: false,
//       body: child,
//       bottomNavigationBar: SlantedAnimatedBottomBar(
//         items: garageBottomNavItems,
//         defaultIndex: 2,
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/providers/auth_provider.dart';
import 'package:road_assist/ui/call/view/incoming_call_listener.dart';
import 'package:road_assist/ui/navigation/configs/garage_bottom_nav.dart';
import 'package:road_assist/ui/navigation/widgets/slanted_animated_bottom_bar.dart';

class GarageMainScreen extends ConsumerWidget {
  final Widget child;

  const GarageMainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garageId = ref.watch(userIdProvider);

    if (garageId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          body: child,
          bottomNavigationBar: SlantedAnimatedBottomBar(
            items: garageBottomNavItems,
            defaultIndex: 2,
          ),
        ),

        /// 👂 GARAGE LUÔN LUÔN LISTEN CUỘC GỌI ĐẾN
        IncomingCallListener(currentUserId: garageId),
      ],
    );
  }
}
