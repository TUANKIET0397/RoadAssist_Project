// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:road_assist/core/providers/auth_provider.dart';
// import 'package:road_assist/ui/call/view/incoming_call_listener.dart';
// import 'package:road_assist/ui/navigation/configs/user_bottom_nav.dart';
// import 'package:road_assist/ui/navigation/widgets/slanted_animated_bottom_bar.dart';

// class UserMainScreen extends StatelessWidget {
//   final Widget child;

//   const UserMainScreen({super.key, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return
//     Scaffold(
//       extendBody: false,
//       body: child,
//       bottomNavigationBar: SlantedAnimatedBottomBar(
//         items: userBottomNavItems,
//         defaultIndex: 2,
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/providers/auth_provider.dart';
import 'package:road_assist/ui/call/view/outgoing_call_screen.dart';
import 'package:road_assist/ui/call/viewmodel/call_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/navigation/configs/user_bottom_nav.dart';
import 'package:road_assist/ui/navigation/widgets/slanted_animated_bottom_bar.dart';
import 'package:road_assist/core/providers/navigation_provider.dart';

class UserMainScreen extends ConsumerWidget {
class UserMainScreen extends ConsumerWidget {
  final Widget child;

  const UserMainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userIdProvider);

    if (userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

  Widget build(BuildContext context, WidgetRef ref) {
    final showNavigation = ref.watch(navigationVisibilityProvider);

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: SlantedAnimatedBottomBar(
        items: userBottomNavItems,
        defaultIndex: 0,
      ),

      /// 🔘 NÚT GỌI – CHỈ USER CÓ
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.call),
        onPressed: () async {
          /// ⚠️ TEST: garageId hardcode
          /// Sau này lấy từ garage detail / rescue request
          const garageId = 'fQemYcgYmSQmvhpElWo4muzOHG33';

          try {
            final callId = await ref
                .read(callControllerProvider)
                .startCall(callerId: userId, receiverId: garageId);

            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OutgoingCallScreen(callId: callId),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Lỗi gọi: $e')));
            }
          }
        },
      ),
      bottomNavigationBar: showNavigation
          ? SlantedAnimatedBottomBar(
              items: userBottomNavItems,
              defaultIndex: 2,
            )
          : null,
    );
  }
}
