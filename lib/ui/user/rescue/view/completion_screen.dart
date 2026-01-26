import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodel/completion_vm.dart';
import '../widgets/completion_header.dart';
import '../widgets/completion_info_card.dart';
import '../widgets/completion_rating_card.dart';
import 'package:road_assist/ui/shared/widgets/view_history_button.dart';

class CompletionScreen extends ConsumerStatefulWidget {
  const CompletionScreen({super.key});

  @override
  ConsumerState<CompletionScreen> createState() =>
      _CompletionScreenState();
}

class _CompletionScreenState extends ConsumerState<CompletionScreen> {
  int rating = 0;
  final commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final payload = ref.watch(completionProvider);

    if (payload == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
              const SizedBox(height: 8),
              const Text(
                'Đánh giá',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              CompletionRatingCard(
                garageName: payload.garageName,
                avatar: payload.garageAvatar,
                rating: rating,
                onRatingChanged: (v) => setState(() => rating = v),
                controller: commentController,
                onSubmit: () async {
                  await ref
                      .read(completionProvider.notifier)
                      .submitRating(
                    stars: rating,
                    comment: commentController.text.trim(),
                  );

                  commentController.clear();
                  setState(() => rating = 5);
                },
              ),
              const SizedBox(height: 12),
              ViewHistoryButton(
                onPressed: () {
                  context.pushReplacement('/user/history');
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
