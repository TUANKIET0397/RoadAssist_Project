import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/theme/app_palette.dart';
import 'package:road_assist/ui/user/history/viewmodel/history_vm.dart';
import 'package:road_assist/ui/user/history/widgets/history_card.dart';
import 'package:road_assist/ui/user/history/widgets/history_filter_tabs.dart';
import 'package:road_assist/ui/shared/skeleton/skeleton_widgets.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(HistoryListProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(37, 45, 60, 1),
        title: const Text(
          'Lịch sử cứu hộ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppPalette.bgColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: listAsync.when(
          data: (list) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 16),
                const HistoryFilterTabs(),
                const SizedBox(height: 20),
                if (list.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Chưa có lịch sử cứu hộ',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  )
                else ...[
                  ...list.map((e) => HistoryCard(item: e)),
                ],

                const SizedBox(height: 100),
              ],
            );
          },
          loading: () => ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 16),
              const HistoryFilterTabs(),
              const SizedBox(height: 20),
              ...List.generate(5, (index) => const SkeletonHistoryCard()),
              const SizedBox(height: 100),
            ],
          ),
          error: (err, stack) => Center(
            child: Text(
              'Lỗi: $err',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
