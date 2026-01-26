import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/call_model.dart';

class CallRepository {
  final _db = FirebaseFirestore.instance;

  Future<String> createCall(CallModel call) async {
    final doc = await _db.collection('calls').add(call.toJson());
    return doc.id;
  }

  Future<void> updateStatus(String callId, CallStatus status) {
    return _db.collection('calls').doc(callId).update({'status': status.name});
  }

  Stream<CallModel?> listenIncomingCall(String userId) {
    return _db
        .collection('calls')
        .where('receiverId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          final ringing = snap.docs.where((d) {
            return d['status'] == CallStatus.ringing.name;
          }).toList();

          if (ringing.isEmpty) return null;

          final doc = ringing.first;
          return CallModel.fromJson(doc.id, doc.data());
        });
  }

  Stream<CallModel?> listenCallById(String callId) {
    return _db.collection('calls').doc(callId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return CallModel.fromJson(doc.id, doc.data()!);
    });
  }
}
