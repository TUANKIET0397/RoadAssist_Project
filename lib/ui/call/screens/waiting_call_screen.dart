import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:road_assist/ui/call/screens/call_screen.dart';

class WaitingCallScreen extends StatefulWidget {
  final String callId;
  final String receiverUid;
  final String receiverName;

  const WaitingCallScreen({
    super.key,
    required this.callId,
    required this.receiverUid,
    required this.receiverName,
  });

  @override
  State<WaitingCallScreen> createState() => _WaitingCallScreenState();
}

class _WaitingCallScreenState extends State<WaitingCallScreen> {
  late StreamSubscription<DocumentSnapshot> _callSubscription;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _listenToCallStatus();
  }

  void _listenToCallStatus() {
    _callSubscription = FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.callId)
        .snapshots()
        .listen(
          (snapshot) {
            if (!snapshot.exists || _isNavigating) {
              print(
                '📞 [WaitingCall] Snapshot not exists or already navigating',
              );
              return;
            }

            final status = snapshot.data()?['status'] as String?;
            print('📞 [WaitingCall] Status: $status');

            if (status == 'accepted') {
              // Receiver đã chấp nhận
              print('📞 [WaitingCall] Accepted - navigating to CallScreen');
              _isNavigating = true;
              _callSubscription.cancel();

              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) =>
                        CallScreen(callId: widget.callId, isCaller: true),
                  ),
                );
              }
            } else if (status == 'rejected' || status == 'ended') {
              // Receiver từ chối hoặc kết thúc
              print('📞 [WaitingCall] Rejected/Ended - navigating back');
              _isNavigating = true;
              _callSubscription.cancel();

              if (mounted) {
                try {
                  Navigator.of(context).maybePop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Người dùng từ chối cuộc gọi')),
                  );
                } catch (e) {
                  print('❌ [WaitingCall] Error navigating: $e');
                }
              }
            }
          },
          onError: (e) {
            print('❌ [WaitingCall] Listener error: $e');
            if (!_isNavigating && mounted) {
              _isNavigating = true;
              _callSubscription.cancel();
              try {
                Navigator.of(context).maybePop();
              } catch (e) {
                print('❌ [WaitingCall] Error navigating on error: $e');
              }
            }
          },
          cancelOnError: false,
        );
  }

  void _cancelCall() async {
    if (_isNavigating) return;
    _isNavigating = true;

    _callSubscription.cancel();

    try {
      await FirebaseFirestore.instance
          .collection('calls')
          .doc(widget.callId)
          .update({'status': 'ended'})
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      print('Error canceling call: $e');
    }

    if (mounted) {
      try {
        await Navigator.of(context).maybePop();
      } catch (e) {
        print('Error navigating: $e');
      }
    }
  }

  @override
  void dispose() {
    _callSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Avatar
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage(
                'assets/images/illustrations/avatarDefault.png',
              ),
            ),
            const SizedBox(height: 24),
            // Receiver name
            Text(
              widget.receiverName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // Status
            const Text(
              'Đang gọi...',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 60),
            // Animated dots
            _buildAnimatedDots(),
            const Spacer(),
            // Cancel button
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _cancelCall,
                  customBorder: const CircleBorder(),
                  child: const Icon(
                    Icons.call_end,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedDots() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDot(value, 0),
            const SizedBox(width: 8),
            _buildDot(value, 0.33),
            const SizedBox(width: 8),
            _buildDot(value, 0.66),
          ],
        );
      },
      onEnd: () {
        // Loop lại animation
        setState(() {});
      },
    );
  }

  Widget _buildDot(double animationValue, double delay) {
    final opacity = (sin((animationValue - delay) * 2 * 3.14159) + 1) / 2;
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.withOpacity(opacity),
      ),
    );
  }
}
