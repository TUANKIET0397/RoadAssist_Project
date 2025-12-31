import 'package:flutter/material.dart';

class MainHome extends StatelessWidget {
  const MainHome({super.key});

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 410;
    const double designHeight = 277.5; // 🔥 đúng chiều cao Path
    const double cardHeight = cardWidth * designHeight / 420;

    return ListView(
      children: [
        Transform.translate(
          offset: const Offset(0, -35), // 🔥 kéo lên 30px
          child: Center(
            child: Stack(
              children: [
                /// SHAPE + GRADIENT
                ClipPath(
                  clipper: RPSClipper(),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    width: cardWidth,
                    height: cardHeight,
                    padding: const EdgeInsets.only(top: 42),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromRGBO(53, 63, 84, 1),
                          Color.fromRGBO(34, 40, 52, 1),
                        ],
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Image.asset(
                          'assets/images/illustrations/vehicle1.png',
                          width: 262,
                          height: 168,
                          fit: BoxFit.contain,
                        ),
                        Positioned(
                          bottom: 12,
                          left: 34,
                          child: Transform.rotate(
                            angle: -0.1,
                            child: const Text(
                              'Báo Cáo Sự Cố',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// BORDER
                CustomPaint(
                  size: Size(cardWidth, cardHeight),
                  painter: RPSBorderPainter(),
                ),
              ],
            ),
          ),
        ),

        Transform.translate(
          offset: const Offset(0, -20), // 🔥 kéo lên 20px
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: cardHeight * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _FutureCard('assets/images/icons/transport.png', 'Vận chuyển'),
                _FutureCard('assets/images/icons/gas.png', 'Xăng dầu'),
                _FutureCard('assets/images/icons/warning.png', 'Không rõ'),
                _FutureCard('assets/images/icons/setting.png', 'Máy móc'),
                _FutureCard('assets/images/icons/key.png', 'Chìa khóa'),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: cardHeight * 0.06),
          child: Text(
            'Phương tiện của bạn',
            style: TextStyle(
              color: const Color.fromRGBO(255, 255, 255, 1),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Transform.translate(
          offset: const Offset(0, -35), // 🔥 kéo lên 30px
          child: Center(
            child: Stack(
              children: [
                /// SHAPE + GRADIENT
                ClipPath(
                  clipper: RPSClipper(),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    width: cardWidth,
                    height: cardHeight,
                    padding: const EdgeInsets.only(top: 42),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromRGBO(53, 63, 84, 1),
                          Color.fromRGBO(34, 40, 52, 1),
                        ],
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Image.asset(
                          'assets/images/illustrations/vehicle1.png',
                          width: 262,
                          height: 168,
                          fit: BoxFit.contain,
                        ),
                        Positioned(
                          bottom: 12,
                          left: 34,
                          child: Transform.rotate(
                            angle: -0.1,
                            child: const Text(
                              'Báo Cáo Sự Cố',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// BORDER
                CustomPaint(
                  size: Size(cardWidth, cardHeight),
                  painter: RPSBorderPainter(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RPSBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromRGBO(75, 83, 99, 1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = RPSClipper().getClip(size);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RPSClipper extends CustomClipper<Path> {
  static const double designWidth = 390;
  static const double designHeight = 277.5;

  double w(double x, Size size) => x * size.width / designWidth;
  double h(double y, Size size) => y * size.height / designHeight;

  @override
  Path getClip(Size size) {
    Path path = Path();

    path.moveTo(w(19, size), h(60, size));
    path.cubicTo(
      w(19, size),
      h(48.9543, size),
      w(27.9543, size),
      h(40, size),
      w(39, size),
      h(40, size),
    );

    path.lineTo(w(349, size), h(40, size));
    path.cubicTo(
      w(360.046, size),
      h(40, size),
      w(369, size),
      h(48.9543, size),
      w(369, size),
      h(60, size),
    );

    path.lineTo(w(369, size), h(222.156, size));
    path.cubicTo(
      w(369, size),
      h(232.323, size),
      w(361.372, size),
      h(240.872, size),
      w(351.271, size),
      h(242.026, size),
    );

    path.lineTo(w(41.2709, size), h(277.455, size));
    path.cubicTo(
      w(29.4029, size),
      h(278.811, size),
      w(19, size),
      h(269.529, size),
      w(19, size),
      h(257.584, size),
    );

    path.lineTo(w(19, size), h(60, size));
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ignore: non_constant_identifier_names
Widget _FutureCard(String img, String title) {
  return Container(
    width: 60,
    height: 60,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color.fromRGBO(66, 74, 91, 1), width: 1),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color.fromRGBO(53, 63, 84, 1), Color.fromRGBO(34, 40, 52, 1)],
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(img, height: 30),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}
