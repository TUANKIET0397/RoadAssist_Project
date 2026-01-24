import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_viewmodel.dart';

class UserRescueWaitingScreen extends ConsumerStatefulWidget {
  final String rescueRequestId;
  final Function(String requestId, String? garageId, String? garageName) onNavigateToSuccess;
  final Function(String requestId) onNavigateToNoGarage;
  final Function() onBack;

  const UserRescueWaitingScreen({
    super.key,
    required this.rescueRequestId,
    required this.onNavigateToSuccess,
    required this.onNavigateToNoGarage,
    required this.onBack,
  });

  @override
  ConsumerState<UserRescueWaitingScreen> createState() =>
      _UserRescueWaitingScreenState();
}

class _UserRescueWaitingScreenState
    extends ConsumerState<UserRescueWaitingScreen> {
  late Timer _timeoutTimer;
  int _elapsedSeconds = 0;
  static const int _timeoutDuration = 30; // 3 phút
  bool _timeoutHandled = false;

  @override
  void initState() {
    super.initState();
    _startTimeoutTimer();
  }

  void _startTimeoutTimer() {
    _timeoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _elapsedSeconds++;
      });

      // Nếu quá 3 phút không có garage nhận thì chuyển đến NoGarage
      if (_elapsedSeconds >= _timeoutDuration) {
        _timeoutTimer.cancel();
        _handleTimeout();
      }
    });
  }

  Future<void> _handleTimeout() async {
    if (_timeoutHandled || !mounted) {
      return;
    }

    _timeoutHandled = true;

    try {
      final repo = ref.read(rescueRequestRepoProvider);
      await repo.setRescueRequestTimedOut(widget.rescueRequestId);

      if (mounted) {
        widget.onNavigateToNoGarage(widget.rescueRequestId);
      }
    } catch (e) {
      print('Error handling timeout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi xử lý timeout')),
        );
      }
    }
  }

  Future<void> _cancelRequest() async {
    final repo = ref.read(rescueRequestRepoProvider);
    final success = await repo.cancelRescueRequest(widget.rescueRequestId);

    if (success && mounted) {
      if (_timeoutTimer.isActive) {
        _timeoutTimer.cancel();
      }
      widget.onBack();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã hủy yêu cầu cứu hộ')));
    }
  }

  @override
  void dispose() {
    if (_timeoutTimer.isActive) {
      _timeoutTimer.cancel();
    }
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final rescueRequest = ref.watch(
      currentRescueRequestProvider(widget.rescueRequestId),
    );

    return PopScope(
      onPopInvokedWithResult: (didPop, result) => false,
      child: Scaffold(
        appBar: AppBar(
          leading: SizedBox.shrink(),
          title: const Text('Đang tìm Garage phù hợp...'),
          centerTitle: true,
          backgroundColor: const Color(0xFF0f172a),
        ),
        body: rescueRequest.when(
          data: (request) {
            if (request == null) {
              return const Center(child: Text('Không tìm thấy yêu cầu'));
            }

            // Nếu garage đã nhận thì chuyển đến success screen
            if (request.status == 'accepted') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_timeoutTimer.isActive) {
                  _timeoutTimer.cancel();
                }
                if (mounted) {
                  widget.onNavigateToSuccess(
                    widget.rescueRequestId,
                    request.garageId,
                    request.garageName,
                  );
                }
              });
            }

            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1e3a8a), Color(0xFF0f172a)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      const RadarScanner(),

                      const SizedBox(height: 24),

                      Text(
                        'Đang tìm Garage phù hợp...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Vui lòng chờ trong giây lát',
                        style: TextStyle(
                          color: Colors.blue.shade200,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Vehicle info card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1e3a8a).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.blue.shade700,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Vehicle icon
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade900.withOpacity(
                                      0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.two_wheeler,
                                    color: Colors.blue.shade300,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        request.vehicleType,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        request.vehicleModel,
                                        style: TextStyle(
                                          color: Colors.blue.shade300,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Issue tags - Hiển thị các vấn đề từ request.issues
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: request.issues.map((issue) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade900.withValues(
                                      alpha: 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.blue.shade600,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    issue,
                                    style: TextStyle(
                                      color: Colors.blue.shade200,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Checklist items
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1e3a8a).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.blue.shade700,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildCheckItem(
                              'Thời gian dự kiến trong 1 - 2 phút',
                              true,
                            ),
                            const SizedBox(height: 12),
                            _buildCheckItem('Kiểm tra khả năng cấu hộ', true),
                            const SizedBox(height: 12),
                            _buildCheckItem(
                              'Gửi yêu cầu đến Garage phù hợp',
                              true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Location info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1e3a8a).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.blue.shade700,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.blue.shade300,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Vị trí của bạn',
                                  style: TextStyle(
                                    color: Colors.blue.shade300,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              request.location,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: Colors.blue.shade300,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  request.userPhone,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Cancel button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _cancelRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Hủy yêu cầu cứu hộ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Vui lòng đảm bảo rằng bạn vẫn ở vị trí như ở trên!',
                        style: TextStyle(
                          color: Colors.blue.shade300,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Lỗi: $error')),
        ),
      ),
    );
  }

  Widget _buildCheckItem(String text, bool isChecked) {
    return Row(
      children: [
        Icon(
          isChecked ? Icons.check_circle : Icons.circle_outlined,
          color: isChecked ? Colors.blue.shade400 : Colors.grey.shade600,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class RadarScanner extends StatefulWidget {
  const RadarScanner({super.key});

  @override
  State<RadarScanner> createState() => _RadarScannerState();
}

class _RadarScannerState extends State<RadarScanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return CustomPaint(
            painter: RadarPainterV4(
              angle: _controller.value * 2 * 3.1415926,
            ),
          );
        },
      ),
    );
  }
}

class RadarPainterV4 extends CustomPainter {
  final double angle;
  RadarPainterV4({required this.angle});

  static final Random _rand = Random();

  // 30 điểm radar
  static final List<_Blip> blips = List.generate(30, (_) {
    final r = _rand.nextDouble() * 0.9;
    final a = _rand.nextDouble() * 2 * pi;
    return _Blip(
      Offset(cos(a) * r, sin(a) * r),
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    /// ===== Background =====
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = const Color(0xFF020617),
    );

    /// ===== Grid =====
    final gridPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * i / 4, gridPaint);
    }

    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, size.height),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      gridPaint,
    );

    /// ===== Radar sweep (1 tia) =====
    const sweepWidth = 0.35;

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: angle,
        endAngle: angle + sweepWidth,
        colors: [
          Colors.cyanAccent.withOpacity(0.0),
          Colors.cyanAccent.withOpacity(0.7),
          Colors.cyanAccent.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      angle,
      sweepWidth,
      true,
      sweepPaint,
    );

    /// ===== Blips =====
    for (final blip in blips) {
      final pos = Offset(
        center.dx + blip.offset.dx * radius,
        center.dy + blip.offset.dy * radius,
      );

      final blipAngle =
          atan2(pos.dy - center.dy, pos.dx - center.dx);

      final diff = _angleDiff(blipAngle, angle);

      if (diff < 0.15) {
        blip.intensity = 1.0; // quét trúng
      } else {
        blip.intensity *= 0.94; // fade out
      }

      if (blip.intensity > 0.05) {
        canvas.drawCircle(
          pos,
          3 + blip.intensity * 2,
          Paint()
            ..color = Colors.cyanAccent.withOpacity(blip.intensity),
        );
      }
    }

    /// ===== Outer ring =====
    canvas.drawCircle(
      center,
      radius - 1.5,
      Paint()
        ..color = Colors.cyanAccent.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    /// ===== Center dot =====
    canvas.drawCircle(
      center,
      5,
      Paint()..color = Colors.cyanAccent,
    );
  }

  double _angleDiff(double a, double b) {
    var d = (a - b).abs();
    if (d > pi) d = 2 * pi - d;
    return d;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Blip {
  final Offset offset;
  double intensity = 0;

  _Blip(this.offset);
}
