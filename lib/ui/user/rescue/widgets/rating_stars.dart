import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final int value;

  const RatingStars({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          Icons.star,
          size: 32,
          color: index < value ? Colors.yellow : Colors.white24,
        ),
      ),
    );
  }
}
