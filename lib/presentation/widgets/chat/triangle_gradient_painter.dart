import 'package:flutter/material.dart';

class TriangleGradientPainter extends CustomPainter {
  late final Color color1;
  final Color color2;

  TriangleGradientPainter({
    required this.color1,
    required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color1.withOpacity(1.0),   // Sáng tối đa
          color2.withOpacity(0.9),
          color1.withOpacity(0.7),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    final path = Path();

    // Vẽ tam giác chĩa mũi ra ngoài
    path.moveTo(size.width * 0.3, 0); // Điểm trên
    path.lineTo(size.width, size.height * 0.5); // Mũi nhọn bên phải
    path.lineTo(size.width * 0.3, size.height); // Điểm dưới
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}