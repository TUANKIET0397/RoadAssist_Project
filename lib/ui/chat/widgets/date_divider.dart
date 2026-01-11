
import 'package:flutter/material.dart';

class DateDivider extends StatelessWidget {
  final String date;

  const DateDivider({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          date,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF94a3b8),
          ),
        ),
      ),
    );
  }
}