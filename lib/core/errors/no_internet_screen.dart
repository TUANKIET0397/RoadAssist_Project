import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/errors/widgets/emergency_card.dart';
import 'package:road_assist/core/network/network_service.dart';
import 'package:road_assist/core/network/network_status.dart';

class NoInternetScreen extends ConsumerStatefulWidget {
  const NoInternetScreen({super.key});

  @override
  ConsumerState<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends ConsumerState<NoInternetScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  bool _checking = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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
    ref.listen<NetworkStatus>(networkStatusProvider, (prev, next) {
      if (prev == NetworkStatus.disconnected &&
          next == NetworkStatus.connected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã kết nối Internet 🎉'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            stops: [0.0, 0.6, 1.0],
            colors: [
              Color.fromRGBO(14, 26, 43, 1),
              Color.fromRGBO(22, 35, 58, 1),
              Color.fromRGBO(180, 74, 125, 1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const Spacer(),

                /// ===== ILLUSTRATION (ANIMATED) =====
                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {
                    return Opacity(
                      opacity: _opacity.value,
                      child: Transform.scale(
                        scale: _scale.value,
                        child: Image.asset(
                          'assets/images/illustrations/noInternet.png',
                          width: 320,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                /// ===== TITLE =====
                const Text(
                  'Không có kết nối Internet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 2),

                const Text(
                  'Vui lòng kiểm tra Wifi hoặc dữ liệu di động',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromRGBO(55, 233, 226, 1),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 17),

                /// ===== EMERGENCY CARD =====
                const EmergencyCard(),

                const SizedBox(height: 16),

                /// ===== INFO LIST =====
                _buildInfoItem('Ứng dụng tạm thời không thể kết nối Internet.'),
                _buildInfoItem(
                  'Chúng tôi sẽ hoạt động lại ngay khi có Internet.',
                ),
                _buildInfoItem('Một số tính năng sẽ tạm thời bị hạn chế.'),

                const SizedBox(height: 8),

                // const Spacer(),

                /// ===== RETRY BUTTON =====
                Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Chưa có kết nối Internet'),
                              backgroundColor: Colors.orange,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 90,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromRGBO(52, 202, 232, 1),
                                Color.fromRGBO(25, 37, 59, 1),
                              ],
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.white24,
                                offset: Offset(1, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: _checking
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Thử kết nối lại',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Hỗ trợ khẩn cấp luôn sẵn sàng cho bạn.',
                      style: TextStyle(
                        color: Color.fromRGBO(113, 129, 165, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: const [
          Icon(
            Icons.check_circle,
            color: Color.fromRGBO(4, 0, 128, 1),
            size: 18,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '',
              style: TextStyle(color: Color.fromRGBO(113, 129, 165, 1)),
            ),
          ),
        ],
      ),
    ).copyWithText(text);
  }
}

/// 🔧 Extension nhỏ để giữ code sạch
extension _RowTextFix on Widget {
  Widget copyWithText(String text) {
    if (this is Padding) {
      final padding = this as Padding;
      final row = padding.child as Row;
      return Padding(
        padding: padding.padding,
        child: Row(
          children: [
            row.children[0],
            row.children[1],
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Color.fromRGBO(113, 129, 165, 1)),
              ),
            ),
          ],
        ),
      );
    }
    return this;
  }
}
