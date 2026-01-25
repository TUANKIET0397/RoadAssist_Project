import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BirthDateField extends StatelessWidget {
  final TextEditingController controller;

  const BirthDateField({super.key, required this.controller});

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color.fromRGBO(75, 76, 237, 1),
              onPrimary: Colors.white,
              surface: Color.fromRGBO(25, 37, 59, 1),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickDate(context),
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Ngày sinh',
            suffixIcon: const Icon(Icons.calendar_month),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }
}
