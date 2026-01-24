import 'package:flutter/material.dart';

class RPSClipperSmall extends CustomClipper<Path> {
  static const double dw = 390;
  static const double dh = 277.5;

  double w(double x, Size s) => x * s.width / dw;
  double h(double y, Size s) => y * s.height / dh;

  @override
  Path getClip(Size s) {
    final p = Path();

    /// TOP LEFT - Bo tròn lớn như trong hình
    p.moveTo(w(20, s), h(70, s));
    p.cubicTo(w(20, s), h(35, s), w(35, s), h(20, s), w(70, s), h(20, s));

    /// TOP RIGHT - Bo tròn nhẹ
    p.lineTo(w(350, s), h(20, s));
    p.cubicTo(w(365, s), h(24, s), w(370, s), h(28, s), w(370, s), h(40, s));

    /// RIGHT SIDE
    p.lineTo(w(371, s), h(220, s));

    /// BOTTOM RIGHT - Cắt xiên
    p.cubicTo(w(369, s), h(235, s), w(355, s), h(240, s), w(340, s), h(245, s));

    /// BOTTOM - Đường xiên
    p.lineTo(w(73, s), h(269, s));

    /// BOTTOM LEFT - Bo tròn VÀO TRONG
    p.quadraticBezierTo(
      w(36, s),
      h(267, s), // Điểm control phía trong
      w(21, s),
      h(240, s), // Điểm kết thúc
    );

    p.close();
    return p;
  }

  @override
  bool shouldReclip(_) => false;
}
