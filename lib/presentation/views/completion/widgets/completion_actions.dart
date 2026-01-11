import 'package:flutter/material.dart';

class CompletionActions extends StatelessWidget {
  final VoidCallback onViewHistory;

  const CompletionActions({super.key, required this.onViewHistory});

  @override
  Widget build(BuildContext) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onViewHistory,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 90),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(25, 37, 59, 1),
                    Color.fromRGBO(52, 202, 232, 1),
                  ],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.white24,
                    offset: Offset(1, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Text(
                'Xem lịch sử cứu hộ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
