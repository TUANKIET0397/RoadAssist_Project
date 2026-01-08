import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/presentation/history/viewmodel/history_vm.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: ListView(children: history.map(Text.new).toList()),
    );
  }
}
