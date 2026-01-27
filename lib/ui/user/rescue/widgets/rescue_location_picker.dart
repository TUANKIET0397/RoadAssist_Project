import 'package:flutter/material.dart';

/// Widget hiển thị và chọn vị trí cứu hộ
class RescueLocationPicker extends StatelessWidget {
  final String? currentAddress;
  final bool isLoading;
  final VoidCallback onTap;

  const RescueLocationPicker({
    super.key,
    required this.currentAddress,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vị trí hiện tại',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF001029),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.blue.shade700,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.map_outlined,
                      color: Colors.blue.shade300,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: isLoading
                          ? const Text(
                              'Đang lấy vị trí...',
                              style: TextStyle(color: Colors.white),
                            )
                          : Text(
                              currentAddress ?? 'Chưa xác định vị trí',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(
                  color: Colors.white38,
                  thickness: 1,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.navigation,
                      color: Colors.blue.shade300,
                      size: 32,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Chọn / cập nhật vị trí',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
