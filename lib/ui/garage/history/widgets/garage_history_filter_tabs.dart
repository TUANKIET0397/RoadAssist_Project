import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/garage/history/viewmodel/garage_history_vm.dart';

class GarageHistoryFilterTabs extends ConsumerWidget {
  const GarageHistoryFilterTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(GarageHistoryProvider);

    Widget tab(String text, GarageHistoryFilter value) {
      final active = current == value;
      return GestureDetector(
        onTap: () => ref.read(GarageHistoryProvider.notifier).setFilter(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFF34CBE8), Color(0xFF1A233B)],
                  )
                : null,
            border: Border.all(color: Colors.blueAccent),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        tab('Tất cả', GarageHistoryFilter.all),
        const SizedBox(width: 10),
        tab('Hoàn Thành', GarageHistoryFilter.completed),
        const SizedBox(width: 10),
        tab('Đã Hủy', GarageHistoryFilter.cancelled),
      ],
    );
  }
}
