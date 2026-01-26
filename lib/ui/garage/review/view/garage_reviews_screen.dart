import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:road_assist/core/auth/auth_state.dart';
import 'package:road_assist/core/providers/auth_provider.dart';
import 'package:road_assist/core/theme/app_palette.dart';

import 'package:road_assist/ui/garage/review/viewmodel/review_vm.dart';
import 'package:road_assist/ui/garage/review/widget/rating_overview.dart';
import 'package:road_assist/ui/garage/review/widget/review_list_item.dart';

import 'package:road_assist/ui/garage/account/viewmodel/garage_vm.dart';
import 'package:road_assist/ui/user/chat/viewmodel/chatList_vm.dart';
import 'package:road_assist/ui/user/chat/view/chatGarage_screen.dart';

class GarageReviewsScreen extends ConsumerStatefulWidget {
  const GarageReviewsScreen({super.key});

  @override
  ConsumerState<GarageReviewsScreen> createState() =>
      _GarageReviewsScreenState();
}

class _GarageReviewsScreenState
    extends ConsumerState<GarageReviewsScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final auth = ref.read(authStateProvider);
      if (!auth.isLoggedIn || auth.userId == null) return;

      final garageId = auth.userId!;

      final garageState = ref.read(garageProvider(garageId));
      final garage = garageState.savedGarage;

      if (garage.id.isEmpty) return;

      ref
          .read(garageReviewProvider.notifier)
          .watchReviews(garage.id);
    });
  }


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(garageReviewProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppPalette.bgColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Đánh giá'),
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            RatingOverview(reviews: state.reviews),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Reviews (${state.reviews.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.reviews.length,
                itemBuilder: (context, index) {
                  final review = state.reviews[index];

                  return ReviewListItem(
                    review: review,
                    onTap: () async {
                      final auth = ref.read(authStateProvider);
                      if (!auth.isLoggedIn || auth.userId == null) return;

                      final chatRepo =
                      ref.read(chatRepositoryProvider);

                      final chatId =
                      await chatRepo.getOrCreateChat(
                        userId: review.userId,
                        garageId: auth.userId!,
                      );

                      if (!context.mounted) return;

                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ChatScreen(chatId: chatId),
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (_, __) =>
                const SizedBox(height: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
