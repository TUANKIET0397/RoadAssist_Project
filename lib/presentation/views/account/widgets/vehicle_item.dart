import 'package:flutter/material.dart';
import '../model/vehicle_model.dart';

class VehicleItem extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onChange;
  final VoidCallback onDelete;

  const VehicleItem({
    super.key,
    required this.vehicle,
    required this.onChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(1.5), // độ dày border
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(0, 0, 0, 0.25),
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
            shape: BoxShape.rectangle,
          ),
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color.fromRGBO(25, 37, 59, 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const SizedBox(width: 120),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        vehicle.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ===== EDIT BUTTON =====
                    InkWell(
                      onTap: onChange,
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF6EC6FF), Color(0xFF00E5FF)],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(1), // độ dày viền
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 13),

                    // ===== DELETE BUTTON =====
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF3D3D), Color(0xFFFF0000)],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF7A1E24),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.delete,
                                size: 16,
                                color: Color(0xFFFF6B7A),
                              ),
                            ),
                          ),
                        ),
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
          child: Image.asset(vehicle.image, width: 120, height: 120),
        ),
      ],
    );
  }
}
