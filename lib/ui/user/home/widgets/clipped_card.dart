import 'package:flutter/material.dart';
import 'package:road_assist/ui/user/home/painters/clipper_border_painter.dart';

class ClippedCard extends StatelessWidget {
  final double width;
  final double heightFactor;
  final Widget child;
  final CustomClipper<Path> clipper;

  const ClippedCard({
    super.key,
    required this.width,
    required this.child,
    required this.clipper,
    this.heightFactor = 1.0,
  });

  static const double designWidth = 390;
  static const double designHeight = 277.5;

  @override
  Widget build(BuildContext context) {
    final baseHeight = width * designHeight / designWidth;
    final height = baseHeight * heightFactor;

    return Stack(
      children: [
        ClipPath(
          clipper: clipper,
          clipBehavior: Clip.antiAlias,
          child: Container(
            width: width,
            height: height,
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
            child: child,
          ),
        ),
        IgnorePointer(
          ignoring: true,
          child: CustomPaint(
            size: Size(width, height),
            painter: ClipperBorderPainter(clipper),
          ),
        ),
      ],
    );
  }
}
