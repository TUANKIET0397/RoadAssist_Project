import 'package:flutter/material.dart';
import 'package:road_assist/core/theme/app_palette.dart';
import 'package:road_assist/ui/user/home/widgets/main_home.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bạn cần hỗ trợ?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.all(10),
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [
                  Color.fromRGBO(79, 172, 254, 1),
                  Color.fromRGBO(0, 242, 254, 1),
                ],
              ),
            ),
            child: const Icon(Icons.search, color: Colors.white),
          ),
        ],
        backgroundColor: const Color.fromRGBO(37, 44, 59, 1),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppPalette.bgColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: MainHome(),
      ),
    );
  }
}
