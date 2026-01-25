import 'package:flutter/material.dart';

class RescueLocationCard extends StatelessWidget {
  final String location;
  final String userPhone;

  const RescueLocationCard({
    super.key,
    required this.location,
    required this.userPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF001029),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vị trí của bạn',
            style: TextStyle(color: Colors.blue.shade200),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.lightBlueAccent,
                fontWeight: FontWeight.w600,
                size: 15,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(3),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
                right: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.phone,
                  color: Colors.blue.shade300,
                ),
                const SizedBox(width: 8),
                Text(
                  userPhone,
                  style: TextStyle(
                    color: Colors.blue.shade300,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
