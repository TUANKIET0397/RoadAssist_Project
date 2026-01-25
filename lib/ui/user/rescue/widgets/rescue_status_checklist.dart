import 'package:flutter/material.dart';

class RescueStatusChecklist extends StatelessWidget {
  final List<String>? items;
  final String? garageName;

  const RescueStatusChecklist({
    super.key,
    this.items,
    this.garageName,
  });

  @override
  Widget build(BuildContext context) {
    final displayItems = items ?? [
      '${garageName ?? 'Garage'} đã nhận cứu hộ',
      'Có thể theo dõi hoặc chat trực tiếp',
      'Garage sẽ liên hệ trong ít phút',
    ];

    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: const Color(0xFF001029),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(displayItems.length, (index) {
          final text = displayItems[index];

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == displayItems.length - 1 ? 0 : 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 3, 4, 82),
                  ),
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
