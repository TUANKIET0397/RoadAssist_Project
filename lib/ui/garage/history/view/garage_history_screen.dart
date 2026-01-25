import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/garage/history/viewmodel/garage_history_vm.dart';
import 'package:road_assist/ui/garage/history/widgets/garage_history_card.dart';
import 'package:road_assist/ui/garage/history/widgets/garage_history_filter_tabs.dart';

class GarageHistoryScreen extends ConsumerWidget {
  const GarageHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(GarageHistoryListProvider);

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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B1C2D), Color(0xFF2F52FF)],
          ),
        ),
        child: listAsync.when(
          data: (list) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 16),
                const GarageHistoryFilterTabs(),
                const SizedBox(height: 20),
                if (list.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Chưa có lịch sử cứu hộ',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                else
                  ...list.map((e) => GarageHistoryCard(item: e)),
                const SizedBox(height: 100),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
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
