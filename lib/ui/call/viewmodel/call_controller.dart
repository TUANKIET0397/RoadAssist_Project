import '../data/call_repository.dart';
import '../models/call_model.dart';

class CallController {
  final CallRepository repo;

  CallController(this.repo);

  Future<String> startCall({
    required String callerId,
    required String receiverId,
  }) async {
    final channel =
        'call_${callerId}_${receiverId}_${DateTime.now().millisecondsSinceEpoch}';

    final call = CallModel(
      id: '',
      channel: channel,
      callerId: callerId,
      receiverId: receiverId,
      status: CallStatus.ringing,
    );

    return await repo.createCall(call);
  }

  Future<void> acceptCall(CallModel call) async {
    await repo.updateStatus(call.id, CallStatus.accepted);
  }

  Future<void> endCall(CallModel call) async {
    await repo.updateStatus(call.id, CallStatus.ended);
  }
}
