import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/account_garage/viewmodel/garage_vm.dart';

class WorkingDaysSelector extends ConsumerWidget {
  const WorkingDaysSelector({super.key});

  static const days = {
    1: 'Thứ 2',
    2: 'Thứ 3',
    3: 'Thứ 4',
    4: 'Thứ 5',
    5: 'Thứ 6',
    6: 'Thứ 7',
    7: 'CN',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workingDays = ref.watch(garageProvider).workingDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ngày hoạt động',
          style: TextStyle(
            color: Color.fromRGBO(127, 199, 252, 1),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        /// 🔥 KHÔNG XUỐNG HÀNG
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: days.entries.map((e) {
              final selected = workingDays.contains(e.key);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    ref.read(garageProvider.notifier).toggleWorkingDay(e.key);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.cyan.withOpacity(0.25)
                          : const Color(0xFF0F1C2E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? Colors.cyanAccent : Colors.grey,
                      ),
                    ),
                    child: Text(
                      e.value,
                      style: TextStyle(
                        color: selected ? Colors.cyanAccent : Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
