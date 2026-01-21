import 'package:flutter/material.dart';
import 'package:road_assist/ui/user/garage/viewmodel/garageDetail_viewmodel.dart';
import 'rating_bar_item.dart';

class RatingOverview extends StatelessWidget {
  final GarageDetailState state;

  const RatingOverview({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1C2A5A), Color(0xFF274D9A)],
        ),
      ),
      child: Row(
        children: [
          // Left: average
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.averageRating.toStringAsFixed(1),
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
                    i < state.averageRating.round()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Based on ${state.totalReviews} reviews',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(width: 24),

          // Right: bars
          Expanded(
            child: Column(
              children: List.generate(
                5,
                (i) => RatingBarItem(star: 5 - i, reviews: state.reviews),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
