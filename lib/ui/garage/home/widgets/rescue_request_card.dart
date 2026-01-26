import 'package:flutter/material.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:road_assist/data/datasources/local/vehicle_constants.dart';

class RescueRequestCard extends StatelessWidget {
  final RescueRequestModel request;
  final VoidCallback? onAccept;

  const RescueRequestCard({super.key, required this.request, this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF1B1E3C), Color(0xFF11132A)],
        ),
      ),
      child: Row(
        children: [
          // 🚲 Vehicle image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              kVehicleImages[request.vehicleType] ?? 'assets/images/illustrations/vehicle.png',
              width: 70,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.issues.join(', '),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(
                      Icons.circle,
                      size: 8,
                      color: Colors.greenAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '1.3 km',
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${request.getTimeAgo()}',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ✅ Accept button
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF353F54),
              border: GradientBoxBorder(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 255, 0, 94),
                    Color.fromARGB(255, 88, 3, 119),
                  ],
                ),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SizedBox(
              height: 36,
              child: TextButton(
                onPressed: onAccept,  
                child: const Text(
                  'Nhận',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
