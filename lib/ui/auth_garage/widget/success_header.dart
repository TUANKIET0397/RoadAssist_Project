import 'package:flutter/material.dart';

class SuccessHeader extends StatefulWidget {
  const SuccessHeader({super.key});

  @override
  State<SuccessHeader> createState() => _SuccessHeaderState();
}

class _SuccessHeaderState extends State<SuccessHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
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
        // Animated Shield Icon
        Image.asset(
          'assets/images/illustrations/success_shield.png',
          width: 160,
          height: 160,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 24),

        // Success Text
        FadeTransition(
          opacity: _fadeAnimation,
          child: const Column(
            children: [
              Text(
                'Đăng kí Garage Thành Công',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'Tài khoản Garage của bạn đã được kích hoạt',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Bạn có thể bắt đầu dịch vụ cứu hộ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
