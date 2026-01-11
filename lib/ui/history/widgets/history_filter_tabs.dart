import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/history/viewmodel/history_vm.dart';

class HistoryFilterTabs extends ConsumerWidget {
  const HistoryFilterTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(HistoryProvider);

    Widget tab(String text, HistoryFilter value) {
      final active = current == value;
      return GestureDetector(
        onTap: () => ref.read(HistoryProvider.notifier).setFilter(value),
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
        tab('Tất cả', HistoryFilter.all),
        const SizedBox(width: 10),
        tab('Hoàn Thành', HistoryFilter.completed),
        const SizedBox(width: 10),
        tab('Thất Bại', HistoryFilter.failed),
      ],
    );
  }
}
