import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/call_providers.dart';
import '../models/call_model.dart';
import 'call_screen.dart';

class OutgoingCallScreen extends ConsumerWidget {
  final String callId;

  const OutgoingCallScreen({super.key, required this.callId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(callRepositoryProvider);

    return StreamBuilder<CallModel?>(
      stream: repo.listenCallById(callId),
      builder: (context, snapshot) {
        final call = snapshot.data;
        if (call == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (call.status == CallStatus.accepted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => CallScreen(call: call)),
            );
          });
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Đang gọi...')),
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                await ref.read(callControllerProvider).endCall(call);
                Navigator.pop(context);
              },
              child: const Text('Hủy'),
            ),
          ),
        );
      },
    );
  }
}
