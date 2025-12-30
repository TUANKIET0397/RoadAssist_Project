import 'package:flutter/material.dart';

class MainHome extends StatelessWidget {
  const MainHome({super.key});

  get image => null;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 2),
              padding: EdgeInsets.only(top: 10),
              width: 350,
              height: 240,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromRGBO(53, 63, 84, 1),
                    Color.fromRGBO(34, 40, 52, 1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color.fromRGBO(75, 83, 99, 1),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(16, 20, 28, 0.6),
                    spreadRadius: 2,
                    blurRadius: 5,

                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: ClipPath(
                clipper: null,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Image.asset(
                      'assets/images/illustrations/vehicle1.png',
                      width: 262,
                      height: 168,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 0,
                      left: 10,
                      child: Container(
                        transform: Matrix4.rotationZ(-0.1),
                        child: Text(
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
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _FutureCard('assets/images/icons/transport.png', 'Vận chuyển'),
                _FutureCard('assets/images/icons/gas.png', 'Xăng dầu'),
                _FutureCard('assets/images/icons/warning.png', 'Không rõ'),
                _FutureCard('assets/images/icons/setting.png', 'Máy móc'),
                _FutureCard('assets/images/icons/key.png', 'Chìa khóa'),
              ],
            ),
          ],
        );
      },
    );
  }
}

Widget _FutureCard(String img, String title) {
  return Container(
    width: 70,
    height: 70,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Color.fromRGBO(66, 74, 91, 1), width: 1),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color.fromRGBO(53, 63, 84, 1), Color.fromRGBO(34, 40, 52, 1)],
      ),
    ),
    child: Column(
      children: [
        IconButton(
          iconSize: 24,
          onPressed: () {},
          icon: Image.asset(img, height: 27),
        ),

        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}
