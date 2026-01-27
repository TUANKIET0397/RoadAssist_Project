import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:road_assist/core/auth/auth_state.dart';
import 'package:road_assist/core/providers/auth_provider.dart';
import 'package:road_assist/core/theme/app_palette.dart';

import 'package:road_assist/ui/garage/review/viewmodel/review_vm.dart';
import 'package:road_assist/ui/garage/review/widget/rating_overview.dart';
import 'package:road_assist/ui/garage/review/widget/review_list_item.dart';
import 'package:road_assist/ui/shared/skeleton/skeleton_widgets.dart';

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
            ? Column(
          children: [
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1e2538),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 150,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: 120,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e2538),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 120,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[700],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 80,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 200,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
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
