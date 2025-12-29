import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home page of road assist',
      home: SafeArea(child: Scaffold(body: Text('hello road assist'))),
      debugShowCheckedModeBanner: false,
    );
  }
}
