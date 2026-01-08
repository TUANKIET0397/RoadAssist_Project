import 'package:flutter/material.dart';
import 'package:road_assist/presentation/views/home/view/main_home.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Bạn cần hỗ trợ?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
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
