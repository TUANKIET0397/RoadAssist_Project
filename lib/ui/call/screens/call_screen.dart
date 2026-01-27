import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/call/services/call_service.dart';
import 'package:road_assist/ui/user/chat/viewmodel/chatList_vm.dart';

/// ======================
/// CALL SCREEN (UI GIỮ NGUYÊN)
/// ======================
class CallScreen extends ConsumerStatefulWidget {
  final String callId;
  final bool isCaller;

  const CallScreen({super.key, required this.callId, required this.isCaller});

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  final CallService _service = CallService();
  bool isMuted = false;
  bool isSpeakerOn = true;
  int seconds = 0;
  Timer? _timer;
  StreamSubscription? _callEndSubscription;
  bool _isEnding = false;

  @override
  void initState() {
    super.initState();
    _service.startCall(callId: widget.callId, isCaller: widget.isCaller);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => seconds++);
    });

    // Listen for when the other party ends the call
    _listenForCallEnd();

    // Also set a timeout - if no response from other party after 60 seconds, auto-end
    Future.delayed(const Duration(seconds: 60), () {
      if (mounted && !_isEnding && _timer != null) {
        print('📞 Call timeout - auto ending call');
        _endCall();
      }
    });
  }

  void _listenForCallEnd() {
    _callEndSubscription = FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.callId)
        .snapshots()
        .listen(
          (doc) {
            if (!mounted || _isEnding) return;

            final status = doc.data()?['status'] as String?;
            print('📞 [CallScreen] Call status: $status');

            // Check if document still exists
            if (!doc.exists) {
              print('📞 [CallScreen] Call document deleted');
              _handleCallEnded();
              return;
            }

            if (status == 'ended' || status == 'rejected') {
              print('📞 [CallScreen] Other party ended/rejected call');
              _handleCallEnded();
            }
          },
          onError: (e) {
            print('❌ [CallScreen] Listener error: $e');
            // Even on error, try to close connection and navigate
            if (!_isEnding && mounted) {
              print('📞 [CallScreen] Handling error by ending call');
              _handleCallEnded();
            }
          },
          cancelOnError: false, // Don't auto-cancel on error
        );
  }

  void _handleCallEnded() {
    if (_isEnding) return;
    _isEnding = true;

    print('📞 [_handleCallEnded] Call ended by other party');

    // Cancel listener first
    _cancelSubscription();

    // Send call history message
    _sendCallHistory();

    // Close service in background (don't wait)
    Future.microtask(() {
      try {
        print('📞 [_handleCallEnded] Closing WebRTC connection');
        _service.closeConnection();
        print('✅ [_handleCallEnded] Connection closed');
      } catch (e) {
        print('❌ [_handleCallEnded] Error closing service: $e');
      }
    });

    // Pop back to previous screen
    if (mounted) {
      try {
        print('📞 [_handleCallEnded] Popping CallScreen');
        Navigator.of(context).pop();
        print('✅ [_handleCallEnded] Popped');
      } catch (e) {
        print('❌ [_handleCallEnded] Error navigating: $e');
      }
    }
  }

  void _cancelSubscription() {
    _callEndSubscription?.cancel();
    _callEndSubscription = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cancelSubscription();
    super.dispose();
  }

  String formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _endCall() async {
    if (_isEnding) return;
    _isEnding = true;

    print('📞 [_endCall] User pressed end call button');

    // Cancel listener immediately to prevent race conditions
    _cancelSubscription();

    try {
      // Update Firebase FIRST - this must reach the other side
      print('📞 [_endCall] Updating Firebase status to ended');
      await FirebaseFirestore.instance
          .collection('calls')
          .doc(widget.callId)
          .update({'status': 'ended', 'endedAt': DateTime.now()})
          .timeout(
            const Duration(seconds: 2),
            onTimeout: () {
              print('⚠️ [_endCall] Firebase update timeout but continuing');
              return; // Continue even if timeout
            },
          );
      print('✅ [_endCall] Firebase updated successfully');
    } catch (e) {
      print('❌ [_endCall] Error updating Firebase: $e');
      // Continue anyway
    }

    // Send call history message
    _sendCallHistory();

    // Close service in background - don't block navigation
    Future.microtask(() {
      try {
        print('📞 [_endCall] Closing WebRTC connection');
        _service.closeConnection();
        print('✅ [_endCall] WebRTC connection closed');
      } catch (e) {
        print('❌ [_endCall] Error closing service: $e');
      }
    });

    // Pop back to previous screen
    if (mounted) {
      try {
        print('📞 [_endCall] Popping CallScreen');
        Navigator.of(context).pop();
        print('✅ [_endCall] Popped');
      } catch (e) {
        print('❌ [_endCall] Error navigating: $e');
      }
    }
  }

  /// Send call history message to chat
  /// Only sends from caller to avoid duplicate messages
  Future<void> _sendCallHistory() async {
    try {
      // Only send history from caller
      if (!widget.isCaller) {
        print('📞 Not caller, skipping history message');
        return;
      }

      // Get call document to find callerId and receiverId
      final callDoc = await FirebaseFirestore.instance
          .collection('calls')
          .doc(widget.callId)
          .get();

      if (!callDoc.exists) {
        print('⚠️ Call document not found, skipping history message');
        return;
      }

      final callData = callDoc.data();
      final callerId = callData?['callerId'] as String?;
      final receiverId = callData?['receiverId'] as String?;

      if (callerId == null || receiverId == null) {
        print('⚠️ Missing callerId or receiverId, skipping history message');
        return;
      }

      // Only send if call was accepted (not rejected)
      final status = callData?['status'] as String?;
      if (status == 'rejected') {
        print('📞 Call was rejected, skipping history message');
        return;
      }

      // Only send if call duration is more than 0 (call was actually connected)
      if (seconds == 0) {
        print('📞 Call duration is 0, skipping history message');
        return;
      }

      // Get chat repository and send history message
      final chatRepo = ref.read(chatRepositoryProvider);
      await chatRepo.sendCallHistoryMessage(
        callerId: callerId,
        receiverId: receiverId,
        durationSeconds: seconds,
      );

      print('✅ Call history message sent successfully');
    } catch (e) {
      print('❌ Error sending call history message: $e');
      // Don't throw - this is a non-critical operation
    }
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
                backgroundImage: AssetImage(
                  'assets/images/illustrations/avatarDefault.png',
                ),
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
                formatTime(seconds),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
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
                      },
                    ),
                    _btn(
                      icon: isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                      onTap: () => setState(() => isSpeakerOn = !isSpeakerOn),
                    ),
                    _btn(
                      icon: Icons.call_end,
                      color: Colors.red,
                      onTap: _isEnding ? null : _endCall,
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
    required VoidCallback? onTap,
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
