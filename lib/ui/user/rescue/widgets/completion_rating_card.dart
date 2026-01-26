import 'package:flutter/material.dart';
import 'package:road_assist/ui/user/rescue/widgets/rating_stars.dart';

class CompletionRatingCard extends StatelessWidget {
  final String garageName;
  final String avatar;

  final int rating;
  final ValueChanged<int> onRatingChanged;

  final TextEditingController controller;
  final VoidCallback onSubmit;

  const CompletionRatingCard({
    super.key,
    required this.garageName,
    required this.avatar,
    required this.rating,
    required this.onRatingChanged,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = controller.text.trim().isEmpty;

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
              CircleAvatar(
                radius: 26,
                backgroundImage: AssetImage(avatar),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    garageName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  RatingStars(
                    value: rating,
                    onChanged: onRatingChanged,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.cyanAccent),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Chia sẻ trải nghiệm cá nhân của bạn',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color:
                    isDisabled ? Colors.white24 : Colors.cyanAccent,
                  ),
                  onPressed: isDisabled ? null : onSubmit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
