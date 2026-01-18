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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(color: Colors.white)),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}
