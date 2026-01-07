import 'package:flutter/material.dart';
import 'package:road_assist/presentation/views/home/main_home.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home page of road assist',
      home: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            'Bạn cần hỗ trợ?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Action for search button
              },
            ),
          ],

          backgroundColor: Color.fromRGBO(37, 44, 59, 1),
        ),

        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(56, 56, 224, 1),
                Color.fromRGBO(46, 144, 183, 1),
              ],
            ),
          ),
          child: MainHome(),
        ),

        bottomNavigationBar: const SlantedAnimatedBottomBar(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SlantedAnimatedBottomBar extends StatefulWidget {
  const SlantedAnimatedBottomBar({super.key});

  @override
  State<SlantedAnimatedBottomBar> createState() =>
      _SlantedAnimatedBottomBarState();
}

class _SlantedAnimatedBottomBarState extends State<SlantedAnimatedBottomBar>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 2;

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
    setState(() => _currentIndex = index);
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
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
          /// ================= BAR =================
          Positioned.fill(
            child: ClipPath(
              clipper: SlantedBarClipper(),
              child: Container(
                height: 90,
                color: const Color.fromRGBO(37, 44, 59, 1),
                child: Row(
                  children: List.generate(itemCount, (index) {
                    final item = _items[index];
                    final isActive = index == _currentIndex;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onTap(index),
                        behavior: HitTestBehavior.translucent,
                        child: isActive
                            ? const SizedBox() // chừa chỗ cho icon nổi
                            : _NormalItem(item: item),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),

          /// ================= ACTIVE ICON =================
          AnimatedPositioned(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutBack,
            bottom: 24,
            left: itemWidth * _currentIndex + itemWidth / 2 - activeSize / 2,
            child: GestureDetector(
              onTap: () => _onTap(_currentIndex),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Transform.translate(
                    offset: Offset(0, _lift.value),
                    child: Transform.scale(
                      scale: _scale.value,
                      child: ClipPath(
                        clipper: SlantedBarClipper(), //
                        child: Container(
                          padding: const EdgeInsets.all(iconPadding),
                          color: const Color.fromRGBO(52, 200, 232, 1),
                          child: Image.asset(
                            _items[_currentIndex].icon,
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
    path.moveTo(0, 20); // 🔥 cắt xéo như cũ
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}
