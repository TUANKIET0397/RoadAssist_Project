import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final int value;
  final ValueChanged<int>? onChanged;
  final int max;

  const RatingStars({
    super.key,
    required this.value,
    this.onChanged,
    this.max = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        max,
            (index) {
          final isActive = index < value;

          return IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              isActive ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 26,
            ),
            onPressed: onChanged == null
                ? null
                : () => onChanged!(index + 1),
          );
        },
      ),
    );
  }
}
