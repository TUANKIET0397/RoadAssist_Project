import 'package:flutter/material.dart';
import 'package:road_assist/ui/user/home/clippers/rps_clipper_small.dart';
import 'package:road_assist/ui/user/home/widgets/clipped_card.dart';

class VehicleGridItem extends StatefulWidget {
  final String title;
  final String subtitle1;
  final String subtitle2;
  final String image;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback? onTap; // Thêm callback khi bấm vào card

  const VehicleGridItem({
    super.key,
    required this.title,
    required this.subtitle1,
    required this.subtitle2,
    required this.image,
    required this.isFavorite,
    required this.onFavoriteTap,
    this.onTap,
  });

  @override
  State<VehicleGridItem> createState() => _VehicleGridItemState();
}

class _VehicleGridItemState extends State<VehicleGridItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );

    _scale = Tween<double>(
      begin: 1,
      end: 1.25,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void didUpdateWidget(covariant VehicleGridItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isFavorite && widget.isFavorite) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return GestureDetector(
          onTap: widget.onTap,
          child: ClippedCard(
            width: width,
            heightFactor: 2, // 🔒 GIỮ NGUYÊN
            clipper: RPSClipperSmall(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ❤️ FAVORITE (ANIMATE NHẸ, KHÔNG PHÁ CLIP)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                    GestureDetector(
                      onTap: widget.onFavoriteTap,
                      child: ScaleTransition(
                        scale: _scale,
                        child: Icon(
                          widget.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.isFavorite
                              ? Colors.red
                              : Colors.white70,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),

                /// 🛵 IMAGE – GIỮ NGUYÊN Expanded
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Image.asset(widget.image, fit: BoxFit.contain),
                  ),
                ),

                const SizedBox(height: 2),

                /// TEXT – BÁM ĐÁY (KHÔNG ĐỤNG)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    widget.subtitle1,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    widget.subtitle2,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }
}
