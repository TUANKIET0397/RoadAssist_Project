import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:road_assist/core/auth/auth_state.dart';
import 'package:road_assist/core/providers/auth_provider.dart';

import 'package:road_assist/data/models/review_model.dart';
import 'package:road_assist/ui/garage/review/viewmodel/review_vm.dart';

import 'package:road_assist/ui/garage/review/widget/rating_overview.dart';
import 'package:road_assist/ui/garage/review/widget/review_list_item.dart';

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
      final userId = ref.read(userIdProvider);
      final role = ref.read(userRoleProvider);

      if (userId != null && role == UserRole.garage) {
        ref
            .read(garageReviewProvider.notifier)
            .watchReviews(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(garageReviewProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(56, 56, 224, 1),
            Color.fromRGBO(46, 144, 183, 1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
            /// OVERVIEW
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

            /// LIST
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.reviews.length,
                itemBuilder: (context, index) {
                  final ReviewModel review = state.reviews[index];

                  return ReviewListItem(
                    review: review,
                    onTap: () async {
                      final auth = ref.read(authStateProvider);
                      if (!auth.isLoggedIn || auth.userId == null) return;

                      final chatRepo =
                      ref.read(chatRepositoryProvider);

                      final garageId = auth.userId!;
                      final userId = review.userId;

                      final garageDoc = await FirebaseFirestore
                          .instance
                          .collection('garages')
                          .doc(garageId)
                          .get();

                      final garageName =
                          garageDoc.data()?['name'] ?? 'Garage';
                      final garageImage =
                          garageDoc.data()?['image'] ?? '';

                      final chatId =
                      await chatRepo.getOrCreateChat(
                        userId: userId,
                        garageId: garageId,
                        garageName: garageName,
                        garageImage: garageImage,
                      );

                      if (!context.mounted) return;

                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(chatId: chatId),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
