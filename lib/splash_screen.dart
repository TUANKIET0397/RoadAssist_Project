import 'dart:math';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const SplashScreen({super.key, required this.onAnimationComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _triangleController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    // Animation cho tam giác di chuyển (4 giây)
    _triangleController = AnimationController(
      duration: Duration(milliseconds: 8000),
      vsync: this,
    )..repeat();

    // Animation fade out (1 giây cuối)
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    // Sau 5 giây, fade out và chuyển màn hình
    Future.delayed(Duration(milliseconds: 8000), () {
      _fadeController.forward().then((_) {
        _triangleController.stop();
        widget.onAnimationComplete();
      });
    });
  }

  @override
  void dispose() {
    _triangleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_triangleController, _fadeController]),
        builder: (context, child) {
          return Opacity(
            opacity: 1 - _fadeController.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [Color.fromARGB(255, 2, 36, 161), Color(0xFF1A1E3D)],
                ),
              ),
              child: Stack(
                children: [
                  _buildMovingTriangle(
                    _triangleController.value,
                    isFirst: true,
                  ),
                  _buildMovingTriangle(
                    _triangleController.value,
                    isFirst: false,
                  ),

                  // Logo ở giữa
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 251,
                          height: 225,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Offset lerpOffset(Offset a, Offset b, double t) {
    return Offset(a.dx + (b.dx - a.dx) * t, a.dy + (b.dy - a.dy) * t);
  }

  Offset _calculatePosition(double progress, bool isFirst) {
    late Offset start;
    late Offset end;

    if (progress < 0.25) {
      final t = progress / 0.25;
      start = Offset(isFirst ? 0.0 : 1.0, isFirst ? 0.2 : 0.8);
      end = Offset(isFirst ? 1.0 : 0.0, isFirst ? 0.2 : 0.8);
      return lerpOffset(start, end, t);
    }

    if (progress < 0.5) {
      final t = (progress - 0.25) / 0.25;
      start = Offset(isFirst ? 1.0 : 0.0, isFirst ? 0.2 : 0.8);
      end = Offset(isFirst ? 1.0 : 0.0, isFirst ? 1.0 : 0.0);
      return lerpOffset(start, end, t);
    }

    if (progress < 0.75) {
      final t = (progress - 0.5) / 0.25;
      start = isFirst ? const Offset(1, 1) : const Offset(0, 0);
      end = const Offset(0.5, 0.5);
      return lerpOffset(start, end, t);
    }

    final t = (progress - 0.75) / 0.25;
    start = const Offset(0.5, 0.5);
    end = isFirst ? const Offset(1, 0) : const Offset(0, 1);
    return lerpOffset(start, end, t);
  }

  double _calculateRotation(Offset self, Offset target) {
    final dx = target.dx - self.dx;
    final dy = target.dy - self.dy;

    return atan2(dy, dx) + pi / 2;
  }

  Widget _buildMovingTriangle(double progress, {required bool isFirst}) {
    final posSelf = _calculatePosition(progress, isFirst);
    final posOther = _calculatePosition(progress, !isFirst);

    final rotation = _calculateRotation(posSelf, posOther);

    return _paintTriangle(posSelf, rotation);
  }

  Widget _paintTriangle(Offset position, double rotation) {
    return Positioned.fill(
      child: CustomPaint(
        painter: TrianglePainter(
          progress: position,
          rotation: rotation,
          colors: const [Color(0xFF37B6E9), Color(0xFF4B4CED)],
        ),
      ),
    );
  }
}
class TrianglePainter extends CustomPainter {
  final Offset progress;
  final double rotation;
  final List<Color> colors;

  TrianglePainter({
    required this.progress,
    required this.rotation,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width * progress.dx;
    final centerY = size.height * progress.dy;

    canvas.save();
    // Di chuyển đến vị trí hiện tại của progress
    canvas.translate(centerX, centerY);
    // Xoay quanh vị trí đó
    canvas.rotate(rotation);

    // Định nghĩa kích thước: Cạnh đứng dài gấp đôi cạnh ngang
    const double baseWidth = 380.0;
    const double verticalHeight = 600.0; 

    final paint = Paint()
      ..shader = LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(
        Rect.fromLTWH(0, -verticalHeight / 2, baseWidth, verticalHeight),
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    final path = Path();

    // VẼ TAM GIÁC VUÔNG ĐỨNG TẠI GỐC (0,0)
    // 1. Điểm đỉnh (Góc nhọn phía trên)
    path.moveTo(0, -verticalHeight / 2); 
    
    // 2. Điểm góc vuông (Nằm ở giữa cạnh đứng)
    path.lineTo(0, verticalHeight / 2); 
    
    // 3. Điểm đáy (Kéo ngang ra để tạo góc nhọn còn lại)
    path.lineTo(baseWidth, verticalHeight / 2); 
    
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TrianglePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.rotation != rotation;
}