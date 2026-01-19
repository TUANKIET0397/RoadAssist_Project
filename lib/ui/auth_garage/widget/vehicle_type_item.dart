import 'package:flutter/material.dart';

class VehicleTypeItem extends StatelessWidget {
  final String? selectedType;
  final List<String> allTypes;
  final ValueChanged<String?>? onChanged;
  final VoidCallback onAdd;
  final VoidCallback? onRemove;
  final bool isAddButton;

  const VehicleTypeItem({
    super.key,
    this.selectedType,
    required this.allTypes,
    this.onChanged,
    required this.onAdd,
    this.onRemove,
    this.isAddButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF000718),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF34CAE8),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Loại phương tiện',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Row(
            children: [
              if (!isAddButton)
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedType,
                    dropdownColor: const Color(0xFF000718),
                    style: const TextStyle(color: Color(0xFF37B6E9), fontSize: 16),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF37B6E9)),
                    items: allTypes.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              IconButton(
                icon: Icon(isAddButton ? Icons.add : Icons.remove, color: Colors.white),
                onPressed: isAddButton ? onAdd : onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
