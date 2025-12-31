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

        bottomNavigationBar: _bottomNavigationBar(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ignore: camel_case_types
class _bottomNavigationBar extends StatefulWidget {
  // ignore: unused_element_parameter
  const _bottomNavigationBar({super.key});

  @override
  State<_bottomNavigationBar> createState() => __bottomNavigationBarState();
}

// ignore: camel_case_types
class __bottomNavigationBarState extends State<_bottomNavigationBar> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // cập nhật item khi bấm
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: SlantedBarClipper(),
      child: SizedBox(
        height: 120,
        width: double.infinity,
        child: BottomNavigationBar(
          selectedItemColor: Color.fromRGBO(
            52,
            200,
            232,
            1,
          ), // màu icon/text khi chọn
          unselectedItemColor: Colors.white70,
          backgroundColor: Color.fromRGBO(37, 44, 59, 1),
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            // messenger
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/icons/messenger.png',
                width: 27,
                height: 27,
              ),
              label: 'Messenger',
            ),
            //Garage
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/icons/map.png',
                width: 27,
                height: 27,
              ),
              label: 'Garage',
            ),
            //home
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/icons/bicycle.png',
                width: 27,
                height: 27,
              ),
              activeIcon: ClipPath(
                clipper: SlantedBarClipper(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(52, 200, 232, 1),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Image.asset(
                    'assets/images/icons/bicycle.png',
                    width: 27,
                    height: 27,
                  ),
                ),
              ),

              label: 'Trang chủ',
            ),
            //history
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/icons/doc.png',
                width: 27,
                height: 27,
              ),
              label: 'Lịch sử',
            ),
            //account
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/icons/user.png',
                width: 27,
                height: 27,
              ),
              label: 'Tài khoản',
            ),
          ],
        ),
      ),
    );
  }
}

class SlantedBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Điểm bắt đầu: góc trên trái, lệch xuống 20px
    path.moveTo(0, 20);
    // Góc trên phải: giữ nguyên
    path.lineTo(size.width, 0);
    // Góc dưới phải
    path.lineTo(size.width, size.height);
    // Góc dưới trái
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}







   // gradient: LinearGradient(
            //   colors: [
            //     Color.fromRGBO(52, 200, 232, 1),
            //     Color.fromRGBO(78, 74, 242, 1),
            //   ],
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            // ),