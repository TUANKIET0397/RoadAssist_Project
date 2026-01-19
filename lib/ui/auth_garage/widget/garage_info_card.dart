import 'package:flutter/material.dart';
import 'package:road_assist/data/models/garage_model.dart';

class GarageInfoCard extends StatelessWidget {
  final GarageModel garage;
  final String openStatus;
  final String openHours;

  const GarageInfoCard({
    super.key,
    required this.garage,
    required this.openStatus,
    required this.openHours,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: DecorationImage(
          image: NetworkImage(
            garage.bgimgUrl ??
                '',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.55), const Color(0xFF0A1220)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              // Main Info Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      garage.imageUrl ?? '',
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, _, __) => Container(
                        width: 90,
                        height: 90,
                        color: const Color(0xFF1E2A38),
                        child: const Icon(
                          Icons.garage,
                          size: 40,
                          color: Colors.white24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Name and Phone
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          garage.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          garage.phone,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: Colors.white24),
              // Status and Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: garage.isActive
                            ? Colors.greenAccent
                            : Colors.redAccent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        openStatus,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: Colors.white24),
                      const SizedBox(width: 6),
                      Text(
                        openHours,
                        style:
                            const TextStyle(color: Colors.white24, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}