import 'package:flutter/material.dart';

class GarageTextField extends StatelessWidget {
  final String label;
  final String subLabel;
  final String value;
  final ValueChanged<String> onChanged;

  const GarageTextField({
    super.key,
    required this.label,
    required this.subLabel,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
          decoration: BoxDecoration(
            color: Color(0xFF0F1C2E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.cyanAccent),
          ),
          child: TextFormField(
            initialValue: value,
            onChanged: onChanged,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: subLabel,
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
