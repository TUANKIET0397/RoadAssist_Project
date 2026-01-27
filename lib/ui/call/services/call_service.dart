import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CallService {
  late RTCPeerConnection _peer;
  MediaStream? _localStream;
  final _firestore = FirebaseFirestore.instance;
  bool _isClosed = false;
  bool _isMuted = false;
  final List<StreamSubscription> _subscriptions = [];
  final _onCallEndedController = StreamController<void>.broadcast();

  /// Stream that emits when the call is ended by the other party
  Stream<void> get onCallEnded => _onCallEndedController.stream;

  Future<void> startCall({
    required String callId,
    required bool isCaller,
  }) async {
    _peer = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    });

    _localStream = await navigator.mediaDevices.getUserMedia({'audio': true});

    for (var track in _localStream!.getTracks()) {
      _peer.addTrack(track, _localStream!);
    }

    _peer.onIceCandidate = (c) {
      if (c.candidate != null) {
        _firestore
            .collection('calls')
            .doc(callId)
            .collection('candidates')
            .add(c.toMap());
      }
    };

    if (isCaller) {
      print('📞 [CallService] Caller creating offer...');
      final offer = await _peer.createOffer();
      await _peer.setLocalDescription(offer);

      print('📞 [CallService] Caller uploading offer to Firebase...');
      await _firestore.collection('calls').doc(callId).update({
        'offer': offer.toMap(),
      });
      print('✅ [CallService] Offer uploaded successfully');

      // Listen for answer with proper state checking
      final answerSub = _firestore
          .collection('calls')
          .doc(callId)
          .snapshots()
          .listen((doc) async {
            if (_isClosed) return; // Don't process if connection closed

            if (doc.data()?['answer'] != null) {
              try {
                print('📞 [CallService] Caller received answer');
                final ans = doc['answer'];
                await _peer.setRemoteDescription(
                  RTCSessionDescription(ans['sdp'], ans['type']),
                );
              } catch (e) {
                print('Error setting remote description: $e');
              }
            }
          });
      _subscriptions.add(answerSub);
    } else {
      // Receiver: wait for offer from caller
      print('📞 [CallService] Receiver waiting for offer from caller...');
      
      var doc = await _firestore.collection('calls').doc(callId).get();

      // If offer not found, retry with timeout
      int retries = 0;
      while ((doc.data() == null || doc.data()!['offer'] == null) && retries < 10) {
        print('⏳ [CallService] Waiting for offer (attempt ${retries + 1}/10)...');
        await Future.delayed(const Duration(seconds: 1));
        doc = await _firestore.collection('calls').doc(callId).get();
        retries++;
      }

      if (doc.data() == null || doc.data()!['offer'] == null) {
        print('❌ [CallService] Offer not received after 10 seconds, call canceled');
        throw Exception('Offer not received from caller after timeout');
      }

      print('✅ [CallService] Offer received after $retries second(s)');

      final offer = doc.data()!['offer'];

      await _peer.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );

      final answer = await _peer.createAnswer();
      await _peer.setLocalDescription(answer);

      await doc.reference.update({
        'answer': answer.toMap(),
        'status': 'accepted',
      });
      
      print('✅ [CallService] Receiver accepted call with answer');
    }

    // Listen for ICE candidates with proper state checking
    final candidateSub = _firestore
        .collection('calls')
        .doc(callId)
        .collection('candidates')
        .snapshots()
        .listen((snap) {
          if (_isClosed) return;

          for (var d in snap.docs) {
            try {
              final c = d.data();
              _peer.addCandidate(
                RTCIceCandidate(
                  c['candidate'],
                  c['sdpMid'],
                  c['sdpMLineIndex'],
                ),
              );
            } catch (e) {
              print('Error adding ICE candidate: $e');
            }
          }
        });
    _subscriptions.add(candidateSub);

    // Listen for call status changes (if other party ends call)
    final statusSub = _firestore
        .collection('calls')
        .doc(callId)
        .snapshots()
        .listen(
          (doc) {
            if (_isClosed) {
              print('📞 [CallService] Status listener - already closed');
              return;
            }

            final status = doc.data()?['status'] as String?;
            print('📞 [CallService] Status changed: $status');

            if (status == 'ended' || status == 'rejected') {
              print(
                '📞 [CallService] Detected call ended/rejected, closing internally',
              );
              _closeInternal();
            }
          },
          onError: (e) {
            print('❌ [CallService] Status listener error: $e');
            if (!_isClosed) {
              _closeInternal();
            }
          },
        );
    _subscriptions.add(statusSub);

    await Helper.setSpeakerphoneOn(true);
  }

  Future<void> endCall(String callId) async {
    try {
      // Update Firebase first before closing
      await _firestore
          .collection('calls')
          .doc(callId)
          .update({'status': 'ended', 'endedAt': DateTime.now()})
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      print('Error updating call status: $e');
    } finally {
      // Always close the connection
      _closeInternal();
    }
  }

  void _closeInternal() {
    if (_isClosed) return; // Prevent duplicate closing
    _isClosed = true;

    // Cancel all subscriptions
    for (var sub in _subscriptions) {
      try {
        sub.cancel();
      } catch (e) {
        print('Error canceling subscription: $e');
      }
    }
    _subscriptions.clear();

    try {
      _peer.close();
    } catch (e) {
      print('Error closing peer connection: $e');
    }

    try {
      _localStream?.dispose();
    } catch (e) {
      print('Error disposing media stream: $e');
    }
  }

  /// Public method to close connection when user ends the call
  void closeConnection() {
    _closeInternal();
  }

  /// Toggle mute/unmute audio
  void toggleMute() {
    if (_localStream == null) return;
    _isMuted = !_isMuted;
    for (var track in _localStream!.getAudioTracks()) {
      track.enabled = !_isMuted;
    }
  }

  /// Get current mute state
  bool get isMuted => _isMuted;

  void dispose() {
    _closeInternal();
    try {
      _onCallEndedController.close();
    } catch (e) {
      print('Error closing controller: $e');
    }
  }
}
