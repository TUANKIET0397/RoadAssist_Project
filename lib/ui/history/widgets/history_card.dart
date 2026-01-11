import 'package:flutter/material.dart';
import 'package:road_assist/ui/history/model/history_item.dart';
import 'history_status_badge.dart';

class HistoryCard extends StatelessWidget {
  final HistoryItem item;

  const HistoryCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0E2A47), Color(0xFF081629)],
        ),
        boxShadow: const [BoxShadow(color: Colors.blueAccent, blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(item.image, width: 90),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.vehicleName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item.vehicleModel,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              HistoryStatusBadge(status: item.status),
            ],
          ),
          const Divider(color: Colors.white24),
          _row(Icons.warning_amber, item.issue),
          _row(Icons.location_on, item.address),
          _row(
            Icons.access_time,
            'Hoàn thành lúc ${item.completedTime}',
            highlight: true,
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.cyanAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: highlight ? Colors.cyanAccent : Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
