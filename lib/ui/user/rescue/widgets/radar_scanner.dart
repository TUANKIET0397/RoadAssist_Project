import 'dart:math';
import 'package:flutter/material.dart';
import 'package:road_assist/core/services/garage_scanner_service.dart';

/// Radar animation widget hiển thị quá trình quét garage
class RadarScanner extends StatefulWidget {
  final ScanPhase phase;
  final int phase1Count;
  final int phase2Count;
  
  const RadarScanner({
    super.key,
    this.phase = ScanPhase.phase1,
    this.phase1Count = 0,
    this.phase2Count = 0,
  });

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
      duration: Duration(seconds: widget.phase == ScanPhase.phase2 ? 3 : 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getRadarColor() {
    switch (widget.phase) {
      case ScanPhase.phase1:
        return Colors.blue;
      case ScanPhase.phase2:
        return Colors.orange;
      case ScanPhase.completed:
        return Colors.green;
      case ScanPhase.failed:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final radarColor = _getRadarColor();
    
    return SizedBox(
      width: 150,
      height: 150,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return CustomPaint(
            painter: _RadarPainter(
              angle: _controller.value * 2 * pi,
              radarColor: radarColor,
              phase: widget.phase,
              phase1Count: widget.phase1Count,
              phase2Count: widget.phase2Count,
            ),
          );
        },
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double angle;
  final Color radarColor;
  final ScanPhase phase;
  final int phase1Count;
  final int phase2Count;
  
  _RadarPainter({
    required this.angle,
    required this.radarColor,
    required this.phase,
    required this.phase1Count,
    required this.phase2Count,
  });

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
      ..color = radarColor.withOpacity(0.15)
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

    /// ===== Radar sweep =====
    const sweepWidth = 0.35;

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: angle,
        endAngle: angle + sweepWidth,
        colors: [
          radarColor.withValues(alpha: 0.0),
          radarColor.withValues(alpha: 0.7),
          radarColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      angle,
      sweepWidth,
      true,
      sweepPaint,
    );

    /// ===== Phase indicators =====
    if (phase1Count > 0) {
      _drawPhaseIndicator(canvas, center, radius * 0.5, phase1Count, Colors.blue);
    }
    if (phase2Count > 0 && phase != ScanPhase.phase1) {
      _drawPhaseIndicator(canvas, center, radius * 0.75, phase2Count, Colors.orange);
    }

    /// ===== Blips =====
    for (final blip in blips) {
      final pos = Offset(
        center.dx + blip.offset.dx * radius,
        center.dy + blip.offset.dy * radius,
      );

      final blipAngle = atan2(pos.dy - center.dy, pos.dx - center.dx);
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
            ..color = radarColor.withValues(alpha: blip.intensity),
        );
      }
    }

    /// ===== Outer ring =====
    canvas.drawCircle(
      center,
      radius - 1.5,
      Paint()
        ..color = radarColor.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    /// ===== Center dot =====
    canvas.drawCircle(
      center,
      5,
      Paint()..color = radarColor,
    );
  }

  void _drawPhaseIndicator(Canvas canvas, Offset center, double r, int count, Color color) {
    for (int i = 0; i < count && i < 8; i++) {
      final angle = (i * 2 * pi) / 8;
      final pos = Offset(
        center.dx + cos(angle) * r,
        center.dy + sin(angle) * r,
      );
      canvas.drawCircle(
        pos,
        4,
        Paint()..color = color.withValues(alpha: 0.8),
      );
    }
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
