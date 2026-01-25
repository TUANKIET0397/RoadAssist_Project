import 'package:flutter/material.dart';

class AddVehicleDialog extends StatefulWidget {
  final Function(String) onAdd;
  final List<String> existingVehicles; // 👈 THÊM

  const AddVehicleDialog({
    super.key,
    required this.onAdd,
    this.existingVehicles = const [], // 👈 THÊM
  });

  @override
  State<AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<AddVehicleDialog> {
  final _controller = TextEditingController();
  String? _selectedVehicle;

  final List<String> _commonVehicles = [
    'Xe Số',
    'Xe Tay ga',
    'Xe Điện',
    'Ô tô',
    'Xe Bus',
    'Xe Tải',
    'Xe Container',
    'Xe Ba Gác',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleAdd() {
    final vehicleType = _selectedVehicle ?? _controller.text.trim();

    if (vehicleType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn hoặc nhập loại phương tiện'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.existingVehicles.contains(vehicleType)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Loại phương tiện "$vehicleType" đã tồn tại'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    widget.onAdd(vehicleType);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E2A38),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: Color(0xFF4FC3F7),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Thêm Loại Phương Tiện',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            const Text(
              'Chọn loại phương tiện:',
              style: TextStyle(
                color: Color(0xFF4FC3F7),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonVehicles.map((vehicle) {
                final isSelected = _selectedVehicle == vehicle;
                final isExisting = widget.existingVehicles.contains(vehicle); // 👈 KIỂM TRA

                return GestureDetector(
                  onTap: isExisting
                      ? null
                      : () {
                    setState(() {
                      _selectedVehicle = vehicle;
                      _controller.clear();
                    });
                  },
                  child: Opacity(
                    opacity: isExisting ? 0.4 : 1.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isExisting
                            ? const Color(0xFF2A2A2A)
                            : isSelected
                            ? const Color(0xFF4FC3F7)
                            : const Color(0xFF001029),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isExisting
                              ? Colors.grey
                              : isSelected
                              ? const Color(0xFF4FC3F7)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            vehicle,
                            style: TextStyle(
                              color: isExisting
                                  ? Colors.grey
                                  : isSelected
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isExisting) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            /// Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(
                        color: Color(0xFF4FC3F7),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Hủy',
                      style: TextStyle(
                        color: Color(0xFF4FC3F7),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleAdd,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF4FC3F7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Thêm',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}