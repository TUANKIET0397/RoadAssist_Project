import 'package:flutter/material.dart';
import '../model/vehicle_model.dart';

class EditVehicleBottomSheet extends StatefulWidget {
  final Vehicle vehicle;
  final void Function(String?) onSubmit;

  const EditVehicleBottomSheet({
    super.key,
    required this.vehicle,
    required this.onSubmit,
  });

  @override
  State<EditVehicleBottomSheet> createState() => _EditVehicleBottomSheetState();
}

class _EditVehicleBottomSheetState extends State<EditVehicleBottomSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.vehicle.description);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ===== HANDLE =====
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const Text(
              'Mô tả phương tiện',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _controller,
              maxLines: 3,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Nhập mô tả...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color.fromRGBO(15, 25, 45, 1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  widget.onSubmit(_controller.text);
                  Navigator.pop(context);
                },
                child: const Text('Cập nhật'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
