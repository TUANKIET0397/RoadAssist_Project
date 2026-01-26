import 'package:flutter/material.dart';

class VehicleSupportItem extends StatelessWidget {
  final String name;
  final VoidCallback onAdd;

  const VehicleSupportItem({
    super.key,
    required this.name,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Loại phương tiện',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
          ),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              color: Color.fromRGBO(80, 141, 188, 1),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.white, size: 30),
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}
