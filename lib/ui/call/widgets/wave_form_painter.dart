import 'dart:math';

import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final double micLevel;
  final bool isLeft;

  WaveformPainter({required this.micLevel, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFF4AF2FF) // 🔥 SÁNG HƠN
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          3 // 🔥 DÀY HƠN
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        4, // 🔥 BLUR NHẸ LẠI
      );

    final path = Path();
    final midY = size.height / 2;

    final maxAmp = micLevel * size.height * 0.45;
    const int points = 48;

    for (int i = 0; i <= points; i++) {
      final x = size.width * (i / points);
      final progress = i / points;

      // giảm biên độ về phía circle
      final attenuation = isLeft ? progress : (1 - progress);

      final y = midY + sin(progress * pi * 2) * maxAmp * attenuation;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.micLevel != micLevel;
  }
}
