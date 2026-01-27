import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'call_screen.dart';

/// ======================
/// INCOMING CALL LISTENER - SHOW DIALOG OVERLAY
/// ======================
class IncomingCallListener extends StatefulWidget {
  final Widget homeScreen;

  const IncomingCallListener({super.key, required this.homeScreen});

  @override
  State<IncomingCallListener> createState() => _IncomingCallListenerState();
}

class _IncomingCallListenerState extends State<IncomingCallListener> {
  String? _lastCallId; // Track last shown call to avoid duplicate dialogs

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('calls')
          .where('receiverId', isEqualTo: currentUid)
          .where('status', isEqualTo: 'calling')
          .snapshots(),
      builder: (context, snapshot) {
        // If there's an incoming call, show dialog on top of current screen
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final call = snapshot.data!.docs.first;
          final callId = call.id;

          // Only show dialog if this is a new call
          if (callId != _lastCallId) {
            _lastCallId = callId;
            print('📞 IncomingCallListener - New call detected: $callId');

            // Show dialog after frame renders
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) => IncomingCallDialog(
                    callId: callId,
                    callerId: call['callerId'],
                  ),
                );
              }
            });
          }
        } else {
          // Reset when no incoming calls
          _lastCallId = null;
        }

        return widget.homeScreen;
      },
    );
  }
}

/// ======================
/// INCOMING CALL DIALOG
/// ======================
class IncomingCallDialog extends StatefulWidget {
  final String callId;
  final String callerId;

  const IncomingCallDialog({
    super.key,
    required this.callId,
    required this.callerId,
  });

  @override
  State<IncomingCallDialog> createState() => _IncomingCallDialogState();
}

class _IncomingCallDialogState extends State<IncomingCallDialog> {
  late StreamSubscription<DocumentSnapshot> _callStatusSubscription;
  String _callerName = '';
  bool _isHandling = false;

  @override
  void initState() {
    super.initState();
    _loadCallerName();
    _listenToCallStatus();
  }

  Future<void> _loadCallerName() async {
    try {
      final callerData = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.callerId)
          .get();

      if (mounted && callerData.exists) {
        setState(() {
          _callerName = callerData.data()?['name'] ?? widget.callerId;
        });
      }
    } catch (e) {
      print('Error loading caller name: $e');
    }
  }

  void _listenToCallStatus() {
    _callStatusSubscription = FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.callId)
        .snapshots()
        .listen(
          (snapshot) {
            if (!snapshot.exists || _isHandling) return;

            final status = snapshot.data()?['status'] as String?;
            print('📞 Incoming call listener - Status: $status');

            // Nếu caller đã hủy cuộc gọi
            if (status == 'ended' || status == 'rejected') {
              print('📞 Caller ended/rejected call, closing incoming screen');
              _handleCallEnded();
            }
          },
          onError: (e) {
            print('❌ Incoming call listener error: $e');
            if (!_isHandling && mounted) {
              _handleCallEnded();
            }
          },
        );
  }

  void _handleCallEnded() {
    if (_isHandling) return;
    _isHandling = true;

    _callStatusSubscription.cancel();

    if (mounted) {
      try {
        Navigator.of(context).pop(); // Close dialog
      } catch (e) {
        print('Error closing dialog: $e');
      }
    }
  }

  void _rejectCall() async {
    if (_isHandling) return;
    _isHandling = true;

    _callStatusSubscription.cancel();

    try {
      await FirebaseFirestore.instance
          .collection('calls')
          .doc(widget.callId)
          .update({'status': 'rejected'})
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      print('Error rejecting call: $e');
    }

    if (mounted) {
      Navigator.of(context).pop(); // Close dialog
    }
  }

  void _acceptCall() async {
    if (_isHandling) return;
    _isHandling = true;

    if (!mounted) return;

    _callStatusSubscription.cancel();

    // Close dialog first
    Navigator.of(context).pop();

    // Then navigate to CallScreen
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CallScreen(callId: widget.callId, isCaller: false),
        ),
      );
    }

    // Update Firebase in background
    try {
      await FirebaseFirestore.instance
          .collection('calls')
          .doc(widget.callId)
          .update({'status': 'accepted'})
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      print('Error accepting call: $e');
    }
  }

  @override
  void dispose() {
    _callStatusSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black87,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Avatar
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage(
                'assets/images/illustrations/avatarDefault.png',
              ),
            ),
            const SizedBox(height: 32),
            // Caller info
            const Text(
              'Cuộc gọi đến',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              _callerName.isNotEmpty ? _callerName : widget.callerId,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Reject button
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _rejectCall,
                      customBorder: const CircleBorder(),
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                // Accept button
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _acceptCall,
                      customBorder: const CircleBorder(),
                      child: const Icon(
                        Icons.call,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
