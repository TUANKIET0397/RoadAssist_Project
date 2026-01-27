import 'dart:io';
import 'package:flutter/material.dart';

/// Widget để chọn và hiển thị ảnh xe
class RescueImagePicker extends StatelessWidget {
  final List<File> selectedImages;
  final VoidCallback onPickImage;
  final ValueChanged<int> onRemoveImage;
  final int maxImages;

  const RescueImagePicker({
    super.key,
    required this.selectedImages,
    required this.onPickImage,
    required this.onRemoveImage,
    this.maxImages = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF001029),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade700,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < selectedImages.length; i++) ...[
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      selectedImages[i],
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => onRemoveImage(i),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (i != selectedImages.length - 1)
              const SizedBox(width: 12),
          ],

          if (selectedImages.length < maxImages) ...[
            if (selectedImages.isNotEmpty)
              const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: onPickImage,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF4B4CED),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Chụp ảnh',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
