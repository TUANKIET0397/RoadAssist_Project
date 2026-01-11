import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/completion_vm.dart';
import '../widgets/completion_actions.dart';
import '../widgets/completion_header.dart';
import '../widgets/completion_info_card.dart';
import '../widgets/completion_rating_card.dart';

class CompletionScreen extends ConsumerWidget {
  const CompletionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payload = ref.watch(completionProvider);

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
              CompletionHeader(
                title: payload.title,
                subtitle: payload.subtitle,
              ),
              CompletionInfoCard(data: payload),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  'Đánh giá',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              CompletionRatingCard(
                garageName: payload.garageName,
                avatar: payload.garageAvatar,
              ),
              const SizedBox(height: 12),
              CompletionActions(
                onViewHistory: () {
                  // TODO: navigate history
                  print('history');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
