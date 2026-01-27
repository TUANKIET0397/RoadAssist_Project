import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class CallInitiationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Garage gọi User - Garage là caller
  Future<String> initiateCallToUser({required String userId}) async {
    final garageUid = _auth.currentUser!.uid;
    final callId = const Uuid().v4();

    await _firestore.collection('calls').doc(callId).set({
      'callerId': garageUid,
      'receiverId': userId,
      'status': 'calling',
      'createdAt': DateTime.now(),
    });

    return callId;
  }

  /// User gọi Garage - User là caller
  Future<String> initiateCallToGarage({required String garageUid}) async {
    final userUid = _auth.currentUser!.uid;
    final callId = const Uuid().v4();

    await _firestore.collection('calls').doc(callId).set({
      'callerId': userUid,
      'receiverId': garageUid,
      'status': 'calling',
      'createdAt': DateTime.now(),
    });

    return callId;
  }

  /// Cancel incoming call
  Future<void> rejectCall(String callId) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': 'rejected',
    });
  }
}
