import 'package:flutter/material.dart';
import 'package:road_assist/ui/home/view/main_home.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBody: true,
      // extendBodyBehindAppBar: true,
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
                colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
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
            colors: [
              Color.fromRGBO(56, 56, 224, 1),
              Color.fromRGBO(46, 144, 183, 1),
            ],
          ),
        ),
        child: const MainHome(),
      ),
    );
  }
}
