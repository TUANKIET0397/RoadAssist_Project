import 'package:flutter/material.dart';
import 'package:road_assist/ui/rescue/widgets/rating_stars.dart';

class CompletionRatingCard extends StatelessWidget {
  final String garageName;
  final String avatar;

  const CompletionRatingCard({
    super.key,
    required this.garageName,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0E2A47), Color(0xFF091C30)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundImage: AssetImage(avatar), radius: 26),

              const SizedBox(width: 12),
              Column(
                children: [
                  Text(
                    garageName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const RatingStars(value: 3),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.cyanAccent),
            ),
            child: const TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Chia sẻ trải nghiệm cá nhân của bạn',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
