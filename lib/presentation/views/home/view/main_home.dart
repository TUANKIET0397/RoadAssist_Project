import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/presentation/views/completion/completion_screen.dart';
import 'package:road_assist/presentation/views/completion/model/completion_payload.dart';
import 'package:road_assist/presentation/views/completion/viewmodel/completion_vm.dart';

class MainHome extends ConsumerWidget {
  const MainHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        /// ================= BIG CARD =================
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            return Transform.translate(
              offset: const Offset(0, -35),
              child: Center(
                child: ClippedCard(
                  width: width,
                  heightFactor: 1.0,
                  clipper: RPSClipperBig(),
                  child: const BigVehicleCardContent(),
                ),
              ),
            );
          },
        ),

        /// ================= FEATURE ICONS =================
        LayoutBuilder(
          builder: (context, constraints) {
            final spacing = constraints.maxWidth * 0.03;

            return Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    FutureCard(
                      icon: 'assets/images/icons/transport.png',
                      title: 'Vận chuyển',
                    ),
                    FutureCard(
                      icon: 'assets/images/icons/gas.png',
                      title: 'Xăng dầu',
                    ),
                    FutureCard(
                      icon: 'assets/images/icons/warning.png',
                      title: 'Không rõ',
                    ),
                    FutureCard(
                      icon: 'assets/images/icons/setting.png',
                      title: 'Máy móc',
                    ),
                    FutureCard(
                      icon: 'assets/images/icons/key.png',
                      title: 'Chìa khóa',
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        /// ================= TITLE =================
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Phương tiện của bạn',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        /// ================= GRID =================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 2,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 6,
              mainAxisSpacing: 0,
              childAspectRatio:
                  0.8, // ✅ FIX: Giảm xuống 0.68 để card cao hơn nữa
            ),
            itemBuilder: (context, index) {
              return const VehicleGridItem(
                title: 'Xe Máy Các Loại',
                subtitle1: 'Tay ga',
                subtitle2: 'Bạn đã đăng ký',
                image: 'assets/images/illustrations/vehicle1.png',
              );
            },
          ),
        ),

        /// ================= TITLE =================
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Phương tiện khác',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        /// ================= GRID =================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 6,
              mainAxisSpacing: 0,
              childAspectRatio:
                  0.8, // ✅ FIX: Giảm xuống 0.68 để card cao hơn nữa
            ),
            itemBuilder: (context, index) {
              return const VehicleGridItem(
                title: 'Xe Máy Các Loại',
                subtitle1: 'Tay ga',
                subtitle2: 'Bạn đã đăng ký',
                image: 'assets/images/illustrations/vehicle1.png',
              );
            },
          ),
        ),

        const SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('DEV: Test Completion'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              ref
                  .read(completionProvider.notifier)
                  .setCompletion(
                    CompletionPayload(
                      title: 'Hoàn thành cứu hộ',
                      subtitle: 'Cảm ơn bạn đã sử dụng RoadAssist',
                      vehicleImage: 'assets/images/illustrations/vehicle1.png',
                      vehicleName: 'Xe tay ga',
                      vehicleModel: 'Honda SH Mode 2025',
                      issue: 'Bể lốp, hư máy',
                      address: '15B Nguyễn Lương Bằng, P25, TP HCM',
                      completedTime: '19:00 08-01-2026',
                      garageName: 'Minh Thuan Motor',
                      garageAvatar: 'assets/images/illustrations/vehicle1.png',
                    ),
                  );

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CompletionScreen()),
              );
            },
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}

/// =======================================================
/// GRID ITEM
/// =======================================================
class VehicleGridItem extends StatelessWidget {
  final String title;
  final String subtitle1;
  final String subtitle2;
  final String image;

  const VehicleGridItem({
    super.key,
    required this.title,
    required this.subtitle1,
    required this.subtitle2,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return ClippedCard(
          width: width,
          heightFactor: 1.73,
          clipper: RPSClipperSmall(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              14,
              26,
              20,
              26,
            ), // ✅ Giảm padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ❤️ FAVORITE
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Icon(
                      Icons.favorite_border,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ],
                ),

                const SizedBox(height: 4), // ✅ Giảm spacing
                /// 🛵 IMAGE – ĂN PHẦN DƯ
                Expanded(
                  flex: 3, // ✅ Cho image nhiều space hơn
                  child: Center(child: Image.asset(image, fit: BoxFit.contain)),
                ),

                const SizedBox(height: 6), // ✅ Giảm spacing
                /// TEXT – BÁM ĐÁY
                Text(
                  subtitle1,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle2,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// =======================================================
/// CLIPPED CARD
/// =======================================================
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
        CustomPaint(
          size: Size(width, height),
          painter: ClipperBorderPainter(clipper),
        ),
      ],
    );
  }
}

/// =======================================================
/// BIG CARD CONTENT
/// =======================================================
class BigVehicleCardContent extends StatelessWidget {
  const BigVehicleCardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 42),
          child: Image.asset(
            'assets/images/illustrations/vehicle1.png',
            width: 260,
          ),
        ),
        Positioned(
          bottom: 14,
          left: 32,
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
    );
  }
}

/// =======================================================
/// BORDER PAINTER
/// =======================================================
class ClipperBorderPainter extends CustomPainter {
  final CustomClipper<Path> clipper;

  ClipperBorderPainter(this.clipper);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromRGBO(75, 83, 99, 1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = clipper.getClip(size);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

/// =======================================================
/// BIG CLIPPER
/// =======================================================
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

/// =======================================================
/// SMALL CLIPPER
/// =======================================================
class RPSClipperSmall extends CustomClipper<Path> {
  static const double dw = 390;
  static const double dh = 277.5;

  double w(double x, Size s) => x * s.width / dw;
  double h(double y, Size s) => y * s.height / dh;

  @override
  Path getClip(Size s) {
    final p = Path();

    /// 🔥 TOP LEFT – NÂNG MIỆNG CARD LÊN
    p.moveTo(w(20, s), h(44, s)); // ⬆️ 52 → 44
    p.cubicTo(
      w(20, s),
      h(30, s), // 38 → 30
      w(32, s),
      h(22, s), // 28 → 22
      w(48, s),
      h(22, s),
    );

    /// TOP RIGHT
    p.lineTo(w(342, s), h(22, s));
    p.cubicTo(w(358, s), h(22, s), w(370, s), h(30, s), w(370, s), h(44, s));

    /// RIGHT SIDE (GIỮ NGUYÊN)
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

/// =======================================================
/// FEATURE CARD
/// =======================================================
class FutureCard extends StatelessWidget {
  final String icon;
  final String title;

  const FutureCard({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color.fromRGBO(66, 74, 91, 1)),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(53, 63, 84, 1),
              Color.fromRGBO(34, 40, 52, 1),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, height: 28),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
