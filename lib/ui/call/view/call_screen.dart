import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/providers/auth_provider.dart';
import '../models/call_model.dart';
import '../viewmodel/call_providers.dart';

class CallScreen extends ConsumerStatefulWidget {
  final CallModel call;
  const CallScreen({super.key, required this.call});

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  bool _joined = false;

  int _uid(String id) => id.hashCode.abs() % 1000000 + 1;

  @override
  void initState() {
    super.initState();
    _joinAgora();
  }

  Future<void> _joinAgora() async {
    if (_joined) return;
    _joined = true;

    final userId = ref.read(userIdProvider);
    if (userId == null) return;

    final agora = ref.read(agoraServiceProvider);
    await agora.join(widget.call.channel, _uid(userId));
  }

  Future<void> _leaveAgora() async {
    await ref.read(agoraServiceProvider).leave();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(callRepositoryProvider);

    return StreamBuilder<CallModel?>(
      stream: repo.listenCallById(widget.call.id),
      builder: (context, snapshot) {
        final call = snapshot.data;

        /// 🚨 CALL BỊ END TỪ BÊN KIA
        if (call == null || call.status == CallStatus.ended) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await _leaveAgora();
            if (mounted) Navigator.pop(context);
          });

          return const Scaffold(
            body: Center(child: Text('Cuộc gọi đã kết thúc')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Đang gọi')),
          body: const Center(
            child: Icon(Icons.phone_in_talk, size: 100, color: Colors.green),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: () async {
              await ref.read(callControllerProvider).endCall(widget.call);
              // KHÔNG pop ở đây – để stream xử lý
            },
            child: const Icon(Icons.call_end),
          ),
        );
      },
    );
  }
}
