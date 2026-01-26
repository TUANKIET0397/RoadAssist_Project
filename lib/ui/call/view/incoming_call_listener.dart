import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/call_providers.dart';
import 'incoming_call_screen.dart';

class IncomingCallListener extends ConsumerWidget {
  final String currentUserId;

  const IncomingCallListener({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(callRepositoryProvider);

    return StreamBuilder(
      stream: repo.listenIncomingCall(currentUserId),
      builder: (context, snapshot) {
        final call = snapshot.data;
        if (call == null) return const SizedBox.shrink();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => IncomingCallScreen(call: call)),
          );
        });

        return const SizedBox.shrink();
      },
    );
  }
}
