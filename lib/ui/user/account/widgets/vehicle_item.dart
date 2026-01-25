import 'package:flutter/material.dart';
import 'package:road_assist/data/datasources/local/vehicle_constants.dart';
import '../model/vehicle_model.dart';

class VehicleItem extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const VehicleItem({
    super.key,
    required this.vehicle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath =
        kVehicleImages[vehicle.type] ??
        'assets/images/illustrations/vehicle.png'; // fallback
    return GestureDetector(
      onTap: onEdit, // 👉 click cả item để edit
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.25),
                  offset: Offset(2, 6),
                  blurRadius: 4,
                ),
              ],
              gradient: const LinearGradient(
                colors: [
                  Color.fromRGBO(52, 202, 232, 1),
                  Color.fromRGBO(75, 76, 237, 1),
                ],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(25, 37, 59, 1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 120),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.type,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          vehicle.description ?? 'Thêm mô tả ...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: vehicle.description == null
                              ? const TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                )
                              : const TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: onEdit,
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: onDelete,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -18,
            bottom: 2,
            left: 2,
            child: Image.asset(
              imagePath,
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
