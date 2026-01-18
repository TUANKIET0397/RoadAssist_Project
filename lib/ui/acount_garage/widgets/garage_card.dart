import 'package:flutter/material.dart';
import 'package:road_assist/ui/acount_garage/models/garage_model.dart';

class GarageCard extends StatelessWidget {
  final Garage garage;

  const GarageCard({super.key, required this.garage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4B5CFF), Color(0xFF0E1B2A)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            garage.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(garage.phone, style: const TextStyle(color: Colors.white70)),
          const Divider(color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: garage.isOpen ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    garage.isOpen ? 'Đang mở cửa' : 'Đã đóng cửa',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              Text(
                '${garage.openTime} - ${garage.closeTime}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
