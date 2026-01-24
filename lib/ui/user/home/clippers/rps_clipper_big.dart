import 'package:flutter/material.dart';

class RPSClipperBig extends CustomClipper<Path> {
  static const double dw = 390;
  static const double dh = 277.5;

  double w(double x, Size s) => x * s.width / dw;
  double h(double y, Size s) => y * s.height / dh;

  @override
  Path getClip(Size s) {
    final p = Path();
    p.moveTo(w(19, s), h(60, s));
    p.cubicTo(w(19, s), h(49, s), w(28, s), h(40, s), w(39, s), h(40, s));
    p.lineTo(w(349, s), h(40, s));
    p.cubicTo(w(360, s), h(40, s), w(369, s), h(49, s), w(369, s), h(60, s));
    p.lineTo(w(369, s), h(222, s));
    p.cubicTo(w(369, s), h(232, s), w(361, s), h(241, s), w(351, s), h(242, s));
    p.lineTo(w(41, s), h(277, s));
    p.cubicTo(w(29, s), h(279, s), w(19, s), h(270, s), w(19, s), h(258, s));
    p.close();
    return p;
  }

  @override
  bool shouldReclip(_) => false;
}
