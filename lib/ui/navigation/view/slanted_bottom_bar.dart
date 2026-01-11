import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/navigation/viewmodel/navigation_viewmodel.dart';

class SlantedAnimatedBottomBar extends ConsumerStatefulWidget {
  final bool popNavigator;
  const SlantedAnimatedBottomBar({super.key, this.popNavigator = false});

  @override
  ConsumerState<SlantedAnimatedBottomBar> createState() =>
      _SlantedAnimatedBottomBarState();
}

class _SlantedAnimatedBottomBarState
    extends ConsumerState<SlantedAnimatedBottomBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _lift;

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
    final current = ref.read(navigationProvider);
    if (current == index) return; // 👈 CHỐNG ANIMATE THỪA

    if (widget.popNavigator) {
      Navigator.of(context).pop();
    }
    ref.read(navigationProvider.notifier).state = index;
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final itemCount = _items.length;
    final itemWidth = screenWidth / itemCount;

    const double iconSize = 28;
    const double iconPadding = 14;
    final double activeSize = iconSize + iconPadding * 2;

    return SizedBox(
      height: 110,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          /// BAR
          Positioned.fill(
            child: ClipPath(
              clipper: SlantedBarClipper(),
              child: Container(
                height: 90,
                color: const Color.fromRGBO(37, 44, 59, 1),
                child: Row(
                  children: List.generate(itemCount, (index) {
                    final item = _items[index];
                    final isActive = index == currentIndex;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onTap(index),
                        behavior: HitTestBehavior.translucent,
                        child: isActive
                            ? const SizedBox()
                            : _NormalItem(item: item),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),

          /// ACTIVE ICON
          AnimatedPositioned(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutBack,
            bottom: 24,
            left: itemWidth * currentIndex + itemWidth / 2 - activeSize / 2,
            child: GestureDetector(
              onTap: () => _onTap(currentIndex),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Transform.translate(
                    offset: Offset(0, _lift.value),
                    child: Transform.scale(
                      scale: _scale.value,
                      child: ClipPath(
                        clipper: SlantedBarClipper(),
                        child: Container(
                          padding: const EdgeInsets.all(iconPadding),
                          color: const Color.fromRGBO(52, 200, 232, 1),
                          child: Image.asset(
                            _items[currentIndex].icon,
                            width: iconSize,
                            height: iconSize,
                            color: Colors.white,
                          ),
                        ),
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

class _NormalItem extends StatelessWidget {
  final BottomItem item;
  const _NormalItem({required this.item});

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

class BottomItem {
  final String icon;
  final String label;
  BottomItem(this.icon, this.label);
}

final List<BottomItem> _items = [
  BottomItem('assets/images/icons/messenger.png', 'Chat'),
  BottomItem('assets/images/icons/map.png', 'Garage'),
  BottomItem('assets/images/icons/bicycle.png', 'Trang chủ'),
  BottomItem('assets/images/icons/doc.png', 'Lịch sử'),
  BottomItem('assets/images/icons/user.png', 'Tài khoản'),
];

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
