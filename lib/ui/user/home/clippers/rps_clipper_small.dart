import 'package:flutter/material.dart';

class RPSClipperSmall extends CustomClipper<Path> {
  static const double dw = 390;
  static const double dh = 277.5;

  double w(double x, Size s) => x * s.width / dw;
  double h(double y, Size s) => y * s.height / dh;

  @override
  Path getClip(Size s) {
    final p = Path();

    /// TOP LEFT
    p.moveTo(w(20, s), h(44, s));
    p.cubicTo(w(20, s), h(30, s), w(32, s), h(22, s), w(48, s), h(22, s));

    /// TOP RIGHT
    p.lineTo(w(342, s), h(22, s));
    p.cubicTo(w(358, s), h(22, s), w(370, s), h(30, s), w(370, s), h(44, s));

    /// RIGHT SIDE
    p.lineTo(w(370, s), h(212, s));

    /// BOTTOM RIGHT
    p.cubicTo(w(370, s), h(228, s), w(350, s), h(238, s), w(330, s), h(240, s));

    /// BOTTOM
    p.lineTo(w(60, s), h(255, s));

    /// BOTTOM LEFT
    p.cubicTo(w(40, s), h(258, s), w(20, s), h(244, s), w(20, s), h(228, s));

    p.close();
    return p;
  }

  @override
  bool shouldReclip(_) => false;
}
