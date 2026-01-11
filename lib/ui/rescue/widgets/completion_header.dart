import 'package:flutter/material.dart';

class CompletionHeader extends StatefulWidget {
  final String title;
  final String subtitle;

  const CompletionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  State<CompletionHeader> createState() => _CompletionHeaderState();
}

class _CompletionHeaderState extends State<CompletionHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scale = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacity = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// ===== SUCCESS ICON (ANIMATED) =====
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Opacity(
              opacity: _opacity.value,
              child: Transform.scale(
                scale: _scale.value,
                child: Image.asset(
                  'assets/images/illustrations/success_shield.png',
                  width: 140,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        /// ===== TITLE =====
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 26,
            color: Color.fromRGBO(166, 254, 180, 1),
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 6),

        /// ===== SUBTITLE =====
        Text(
          widget.subtitle,
          style: const TextStyle(
            color: Color.fromRGBO(114, 126, 151, 1),
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
