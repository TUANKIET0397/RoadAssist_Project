import 'package:flutter/material.dart';

class ClipperBorderPainter extends CustomPainter {
  final CustomClipper<Path> clipper;

  ClipperBorderPainter(this.clipper);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromRGBO(75, 83, 99, 1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = clipper.getClip(size);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
