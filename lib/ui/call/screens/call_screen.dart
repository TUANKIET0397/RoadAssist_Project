import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum CallStatus { connecting, connected }

/// ======================
/// CALL SERVICE (WEBRTC)
/// ======================
class CallService {
  late RTCPeerConnection _peer;
  MediaStream? _localStream;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initPeer({
    required String callId,
    required bool isCaller,
  }) async {
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    _peer = await createPeerConnection(config);

    _localStream = await navigator.mediaDevices.getUserMedia({'audio': true});

    for (var track in _localStream!.getTracks()) {
      _peer.addTrack(track, _localStream!);
    }

    _peer.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        _firestore
            .collection('calls')
            .doc(callId)
            .collection('candidates')
            .add(candidate.toMap());
      }
    };

    if (isCaller) {
      final offer = await _peer.createOffer();
      await _peer.setLocalDescription(offer);

      await _firestore.collection('calls').doc(callId).set({
        'offer': offer.toMap(),
        'status': 'calling',
      });

      _firestore.collection('calls').doc(callId).snapshots().listen((
        doc,
      ) async {
        if (doc.data()?['answer'] != null) {
          final answer = doc['answer'];
          await _peer.setRemoteDescription(
            RTCSessionDescription(answer['sdp'], answer['type']),
          );
        }
      });
    } else {
      final doc = await _firestore.collection('calls').doc(callId).get();
      final offer = doc['offer'];

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

    _firestore
        .collection('calls')
        .doc(callId)
        .collection('candidates')
        .snapshots()
        .listen((snapshot) {
          for (var doc in snapshot.docs) {
            final data = doc.data();
            _peer.addCandidate(
              RTCIceCandidate(
                data['candidate'],
                data['sdpMid'],
                data['sdpMLineIndex'],
              ),
            );
          }
        });

    await Helper.setSpeakerphoneOn(true);
  }

  void toggleMute(bool muted) {
    for (var track in _localStream!.getAudioTracks()) {
      track.enabled = !muted;
    }
  }

  Future<void> endCall(String callId) async {
    await _peer.close();
    await _localStream?.dispose();
    await _firestore.collection('calls').doc(callId).delete();
  }
}

/// ======================
/// CALL SCREEN (UI GIỮ NGUYÊN)
/// ======================
class CallScreen extends StatefulWidget {
  final String callId;
  final bool isCaller;

  const CallScreen({super.key, required this.callId, required this.isCaller});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallService _callService = CallService();

  CallStatus status = CallStatus.connecting;
  bool isMuted = false;
  bool isSpeakerOn = true;

  int seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  Future<void> _initCall() async {
    await _callService.initPeer(
      callId: widget.callId,
      isCaller: widget.isCaller,
    );

    setState(() => status = CallStatus.connected);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _endCall() async {
    await _callService.endCall(widget.callId);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B2B4A), Color(0xFF3B5AE0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              const CircleAvatar(
                radius: 48,
                backgroundImage: AssetImage('assets/avatar.png'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cuộc gọi cứu hộ',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 6),
              const Text(
                'Minh Thuan Motor',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                status == CallStatus.connecting
                    ? 'Đang kết nối với Garage'
                    : 'Đang trò chuyện',
                style: const TextStyle(
                  color: Colors.lightBlueAccent,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                width: 80,
                height: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.6),
                ),
                child: Text(
                  formatTime(seconds),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _btn(
                      icon: isMuted ? Icons.mic_off : Icons.mic,
                      onTap: () {
                        setState(() => isMuted = !isMuted);
                        _callService.toggleMute(isMuted);
                      },
                    ),
                    _btn(
                      icon: isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                      onTap: () => setState(() => isSpeakerOn = !isSpeakerOn),
                    ),
                    _btn(
                      icon: Icons.call_end,
                      color: Colors.red,
                      onTap: _endCall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.black54,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}
