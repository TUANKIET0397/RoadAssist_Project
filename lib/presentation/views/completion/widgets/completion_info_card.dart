import 'package:flutter/material.dart';
import '../model/completion_payload.dart';

class CompletionInfoCard extends StatelessWidget {
  final CompletionPayload data;

  const CompletionInfoCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0E2A47), Color(0xFF091C30)],
        ),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(data.vehicleImage, width: 129),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    maxLines: 1,
                    data.vehicleName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    maxLines: 1,
                    data.vehicleModel,
                    style: const TextStyle(
                      color: Color.fromRGBO(113, 126, 154, 1),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 26),
          _infoRow(
            Icons.warning_amber_rounded,
            data.issue,
            Color.fromRGBO(248, 128, 0, 1),
          ),
          _infoRow(Icons.location_on_outlined, data.address, Colors.cyanAccent),
          _infoRow(
            Icons.access_time,
            'Hoàn thành lúc ' + data.completedTime,
            Colors.cyanAccent,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color.fromRGBO(154, 165, 188, 1),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget _EditText(String text) {
//   return Text(
//     text,
//     style: TextStyle(
//       color: Color.fromRGBO(52, 202, 232, 1),
//       fontSize: 16,
//       fontWeight: FontWeight.w600,
//     ),
//   );
// }
