import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/garage_completion_vm.dart';
import '../widgets/garage_completion_header.dart';
import '../widgets/garage_completion_info_card.dart';
import '../widgets/garage_completion_actions.dart';

class GarageCompletionScreen extends ConsumerWidget {
  const GarageCompletionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payload = ref.watch(garageCompletionProvider);

    if (payload == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B1C2D), Color(0xFF2F52FF)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              GarageCompletionHeader(
                title: payload.title,
                subtitle: payload.subtitle,
              ),
              GarageCompletionInfoCard(data: payload),
              const SizedBox(height: 12),
              GarageCompletionActions(
                onViewHistory: () {
                  context.go('/garage/history');
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
