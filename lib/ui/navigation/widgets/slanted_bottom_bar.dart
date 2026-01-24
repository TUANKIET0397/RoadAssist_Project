// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class SlantedAnimatedBottomBar extends StatefulWidget {
//   const SlantedAnimatedBottomBar({super.key});

//   @override
//   State<SlantedAnimatedBottomBar> createState() =>
//       _SlantedAnimatedBottomBarState();
// }

// class _SlantedAnimatedBottomBarState extends State<SlantedAnimatedBottomBar>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scale;
//   late Animation<double> _lift;

//   static const List<String> _routes = [
//     '/user/chat',
//     '/user/garage',
//     '/user/home',
//     '/user/history',
//     '/user/account',
//   ];

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 320),
//     );

//     _scale = Tween<double>(
//       begin: 1,
//       end: 1.15,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

//     _lift = Tween<double>(
//       begin: 0,
//       end: -26,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

//     _controller.forward();
//   }

//   void _onTap(int index) {
//     final router = GoRouter.of(context);
//     final currentLocation = GoRouterState.of(context).uri.toString();

//     if (currentLocation.startsWith(_routes[index])) return;

//     router.go(_routes[index]);
//     _controller.forward(from: 0);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final location = GoRouterState.of(context).uri.toString();

//     final currentIndex = _routes.indexWhere(
//       (route) => location.startsWith(route),
//     );

//     final activeIndex = currentIndex == -1 ? 2 : currentIndex;

//     final screenWidth = MediaQuery.of(context).size.width;
//     final itemWidth = screenWidth / _items.length;

//     const double iconSize = 28;
//     const double iconPadding = 14;
//     final double activeSize = iconSize + iconPadding * 2;

//     return SizedBox(
//       height: 110,
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           Positioned.fill(
//             child: ClipPath(
//               clipper: SlantedBarClipper(),
//               child: Container(
//                 color: const Color(0xFF252C3B),
//                 child: Row(
//                   children: List.generate(_items.length, (index) {
//                     final item = _items[index];
//                     final isActive = index == activeIndex;

//                     return Expanded(
//                       child: GestureDetector(
//                         onTap: () => _onTap(index),
//                         behavior: HitTestBehavior.translucent,
//                         child: isActive ? const SizedBox() : _NormalItem(item),
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//             ),
//           ),

//           /// ACTIVE ICON
//           AnimatedPositioned(
//             duration: const Duration(milliseconds: 320),
//             curve: Curves.easeOutBack,
//             bottom: 15,
//             left: itemWidth * activeIndex + itemWidth / 2 - activeSize / 2,
//             child: GestureDetector(
//               onTap: () => _onTap(activeIndex),
//               child: AnimatedBuilder(
//                 animation: _controller,
//                 builder: (context, _) {
//                   return Transform.translate(
//                     offset: Offset(0, _lift.value),
//                     child: Transform.scale(
//                       scale: _scale.value,
//                       child: Column(
//                         children: [
//                           ClipPath(
//                             clipper: SlantedRoundedClipper(),
//                             child: Container(
//                               width: 55,
//                               height: 55,
//                               padding: const EdgeInsets.all(iconPadding),
//                               color: const Color(0xFF34C8E8),
//                               child: Image.asset(
//                                 _items[activeIndex].icon,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 2),
//                           Text(
//                             _items[activeIndex].label,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 11,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }

// /* ------------------ SUPPORT CLASSES ------------------ */

// class _NormalItem extends StatelessWidget {
//   final BottomItem item;
//   const _NormalItem(this.item);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Image.asset(item.icon, width: 26, height: 26, color: Colors.white),
//         const SizedBox(height: 4),
//         Text(
//           item.label,
//           style: const TextStyle(color: Colors.white, fontSize: 11),
//         ),
//       ],
//     );
//   }
// }

// class BottomItem {
//   final String icon;
//   final String label;
//   const BottomItem(this.icon, this.label);
// }

// const List<BottomItem> _items = [
//   BottomItem('assets/images/icons/messenger.png', 'Chat'),
//   BottomItem('assets/images/icons/map.png', 'Garage'),
//   BottomItem('assets/images/icons/bicycle.png', 'Trang chủ'),
//   BottomItem('assets/images/icons/doc.png', 'Lịch sử'),
//   BottomItem('assets/images/icons/user.png', 'Tài khoản'),
// ];

// class SlantedBarClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     path.moveTo(0, 20);
//     path.lineTo(size.width, 0);
//     path.lineTo(size.width, size.height);
//     path.lineTo(0, size.height);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(_) => false;
// }

// class SlantedRoundedClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     const double skew = 10;
//     final path = Path();

//     path.moveTo(0, skew + 6);
//     path.quadraticBezierTo(0, skew, 6, skew);
//     path.lineTo(size.width - 8, 0);
//     path.quadraticBezierTo(size.width, 0, size.width, 8);
//     path.lineTo(size.width, size.height - skew - 6);
//     path.quadraticBezierTo(
//       size.width,
//       size.height - skew,
//       size.width - 6,
//       size.height - skew,
//     );
//     path.lineTo(8, size.height);
//     path.quadraticBezierTo(0, size.height, 0, size.height - 8);

//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(_) => false;
// }
