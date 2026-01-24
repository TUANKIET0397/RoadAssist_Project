import 'package:flutter/material.dart';
import 'package:road_assist/data/models/review_model.dart';
import 'rating_bar_item.dart';

class RatingOverview extends StatelessWidget {
  final List<ReviewModel> reviews;

  const RatingOverview({
    super.key,
    required this.reviews,
  });

  double get averageRating {
    if (reviews.isEmpty) return 0;
    return reviews
        .map((e) => e.rating)
        .reduce((a, b) => a + b) /
        reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          /// LEFT
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              Row(
                children: List.generate(
                  5,
                      (i) => Icon(
                    i < averageRating.round()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 18,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Based on ${reviews.length} reviews',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),

          const SizedBox(width: 30),

          /// RIGHT: rating bars
          Expanded(
            child: Column(
              children: List.generate(
                5,
                    (i) => RatingBarItem(
                  star: 5 - i,
                  reviews: reviews,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
