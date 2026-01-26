import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CallService {
  late RTCPeerConnection _peer;
  MediaStream? _localStream;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  /// =============================
  /// INIT PEER
  /// =============================
  Future<void> initPeer() async {
    // Init audio renderer
    await _remoteRenderer.initialize();

    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    _peer = await createPeerConnection(config);

    // 🔥 NHẬN AUDIO TỪ MÁY BÊN KIA
    _peer.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject = event.streams[0];
        print('🎧 Remote audio stream received');
      }
    };

    // LẤY MICRO
    _localStream = await navigator.mediaDevices.getUserMedia({'audio': true});

    for (var track in _localStream!.getTracks()) {
      _peer.addTrack(track, _localStream!);
    }

    // 🔊 BẬT LOA NGOÀI
    await Helper.setSpeakerphoneOn(true);
  }

  /// =============================
  /// CALLER TẠO OFFER
  /// =============================
  Future<void> createCall(String callId) async {
    final offer = await _peer.createOffer();
    await _peer.setLocalDescription(offer);

    await _firestore.collection('calls').doc(callId).set({
      'offer': offer.toMap(),
      'status': 'calling',
    });

    _peer.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        _firestore
            .collection('calls')
            .doc(callId)
            .collection('candidates')
            .add(candidate.toMap());
      }
    };
  }

  /// =============================
  /// RECEIVER NHẬN CALL
  /// =============================
  Future<void> joinCall(String callId) async {
    final doc = await _firestore.collection('calls').doc(callId).get();

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
  }

  /// =============================
  /// ICE CANDIDATE (2 CHIỀU)
  /// =============================
  void listenIce(String callId) {
    _firestore
        .collection('calls')
        .doc(callId)
        .collection('candidates')
        .snapshots()
        .listen((snapshot) {
          for (var doc in snapshot.docs) {
            final data = doc.data();
            if (data['candidate'] != null) {
              _peer.addCandidate(
                RTCIceCandidate(
                  data['candidate'],
                  data['sdpMid'],
                  data['sdpMLineIndex'],
                ),
              );
            }
          }
        });
  }

  /// =============================
  /// END CALL
  /// =============================
  Future<void> endCall(String callId) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': 'ended',
    });

    await _peer.close();
    await _localStream?.dispose();
    await _remoteRenderer.dispose();
  }
}
