import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:road_assist/ui/navigation/widgets/bottom_nav_item.dart.dart';

/// =======================
/// BOTTOM BAR
/// =======================

class SlantedAnimatedBottomBar extends StatefulWidget {
  final List<BottomNavItem> items;
  final int defaultIndex;

  const SlantedAnimatedBottomBar({
    super.key,
    required this.items,
    this.defaultIndex = 0,
  });

  @override
  State<SlantedAnimatedBottomBar> createState() =>
      _SlantedAnimatedBottomBarState();
}

class _SlantedAnimatedBottomBarState extends State<SlantedAnimatedBottomBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _lift;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _scale = Tween<double>(
      begin: 1,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _lift = Tween<double>(
      begin: 0,
      end: -26,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  void _onTap(int index) {
    final router = GoRouter.of(context);
    final currentLocation = GoRouterState.of(context).uri.toString();

    if (currentLocation.startsWith(widget.items[index].route)) return;

    router.go(widget.items[index].route);
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    final currentIndex = widget.items.indexWhere(
      (item) => location.startsWith(item.route),
    );

    final activeIndex = currentIndex == -1 ? widget.defaultIndex : currentIndex;

    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / widget.items.length;

    const double iconSize = 28;
    const double iconPadding = 14;
    final double activeSize = iconSize + iconPadding * 2;

    return SizedBox(
      height: 110,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          /// ===== BACKGROUND BAR =====
          Positioned.fill(
            child: ClipPath(
              clipper: SlantedBarClipper(),
              child: Container(
                color: const Color(0xFF252C3B),
                child: Row(
                  children: List.generate(widget.items.length, (index) {
                    final item = widget.items[index];
                    final isActive = index == activeIndex;

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => _onTap(index),
                        child: isActive ? const SizedBox() : _NormalItem(item),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),

          /// ===== ACTIVE ITEM =====
          AnimatedPositioned(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutBack,
            bottom: 15,
            left: itemWidth * activeIndex + itemWidth / 2 - activeSize / 2,
            child: GestureDetector(
              onTap: () => _onTap(activeIndex),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, __) {
                  return Transform.translate(
                    offset: Offset(0, _lift.value),
                    child: Transform.scale(
                      scale: _scale.value,
                      child: Column(
                        children: [
                          ClipPath(
                            clipper: SlantedRoundedClipper(),
                            child: Container(
                              width: 55,
                              height: 55,
                              padding: const EdgeInsets.all(iconPadding),
                              color: const Color(0xFF34C8E8),
                              child: Image.asset(
                                widget.items[activeIndex].icon,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.items[activeIndex].label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// =======================
/// NORMAL ITEM
/// =======================

class _NormalItem extends StatelessWidget {
  final BottomNavItem item;

  const _NormalItem(this.item);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(item.icon, width: 26, height: 26, color: Colors.white),
        const SizedBox(height: 4),
        Text(
          item.label,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ],
    );
  }
}

/// =======================
/// CLIPPERS
/// =======================

class SlantedBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 20);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}

class SlantedRoundedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double skew = 10;
    final path = Path();

    path.moveTo(0, skew + 6);
    path.quadraticBezierTo(0, skew, 6, skew);
    path.lineTo(size.width - 8, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 8);
    path.lineTo(size.width, size.height - skew - 6);
    path.quadraticBezierTo(
      size.width,
      size.height - skew,
      size.width - 6,
      size.height - skew,
    );
    path.lineTo(8, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - 8);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(_) => false;
}
