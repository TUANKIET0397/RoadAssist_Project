import 'package:flutter/material.dart';
import 'package:road_assist/data/models/review_model.dart';

class RatingBarItem extends StatelessWidget {
  final int star;
  final List<ReviewModel> reviews;

  const RatingBarItem({
    super.key,
    required this.star,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    final total = reviews.length;

    final count = reviews.where((r) {
      return r.rating.round() == star;
    }).length;

    final percent = total == 0 ? 0.0 : count / total;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$star',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star, color: Colors.amber, size: 14),
          const SizedBox(width: 8),

          Expanded(
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.white24,
              valueColor:
              const AlwaysStoppedAnimation<Color>(Color(0xFF2853AF)),
            ),
          ),

          const SizedBox(width: 8),

          Text(
            count.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
