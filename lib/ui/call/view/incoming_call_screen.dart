import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/call_model.dart';
import '../viewmodel/call_providers.dart';
import 'call_screen.dart';

class IncomingCallScreen extends ConsumerWidget {
  final CallModel call;

  const IncomingCallScreen({super.key, required this.call});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cuộc gọi đến')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Từ: ${call.callerId}'),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              await ref.read(callControllerProvider).acceptCall(call);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => CallScreen(call: call)),
              );
            },
            child: const Text('Chấp nhận'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(callControllerProvider).endCall(call);
              Navigator.pop(context);
            },
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
  }
}
