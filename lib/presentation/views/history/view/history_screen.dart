import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/presentation/views/history/viewmodel/history_vm.dart';
import 'package:road_assist/presentation/views/history/widgets/history_card.dart';
import 'package:road_assist/presentation/views/history/widgets/history_filter_tabs.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(HistoryListProvider);

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
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 16),
            const HistoryFilterTabs(),
            const SizedBox(height: 20),
            ...list.map((e) => HistoryCard(item: e)),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
