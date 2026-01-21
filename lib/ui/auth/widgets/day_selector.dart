import 'package:flutter/material.dart';

class DaySelector extends StatelessWidget {
  final Set<int> selectedDays;
  final Function(int) onDayTap;

  const DaySelector({
    super.key,
    required this.selectedDays,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final days = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];

    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = selectedDays.contains(index);

          return GestureDetector(
            onTap: () => onDayTap(index),
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF004BD8)
                    : const Color(0xFF19253B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00D9FF)
                      : Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  days[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Color(0xFF455E96),
                    fontSize: 16,
                    fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
