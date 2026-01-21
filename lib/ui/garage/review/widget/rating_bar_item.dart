import 'package:flutter/material.dart';

class RatingBarItem extends StatelessWidget {
  final int star;
  final List<Map<String, dynamic>> reviews;

  const RatingBarItem({
    super.key,
    required this.star,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    final total = reviews.length;
    final count =
        reviews.where((r) => r['rating'] == star).length;
    final percent = total == 0 ? 0.0 : count / total;

    return Row(
      children: [
        Text(
          '$star',
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.star, size: 14, color: Colors.amber),
        const SizedBox(width: 6),
        Expanded(
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.white24,
            valueColor:
            const AlwaysStoppedAnimation(Colors.blueAccent),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
