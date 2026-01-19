import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/garage_model.dart';
import 'package:road_assist/ui/garage/viewmodel/garageDetail_viewmodel.dart';
import '../widget/rating_overview.dart';
import '../widget/review_list_item.dart';

class GarageReviewsScreen extends ConsumerStatefulWidget {
  final GarageModel garage;

  const GarageReviewsScreen({super.key, required this.garage});

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
      ref
          .read(garageDetailProvider.notifier)
          .watchGarageReviews(widget.garage.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(garageDetailProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1220),
        title: const Text(
          'Đánh giá',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          RatingOverview(state: state),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.reviews.length,
              itemBuilder: (context, index) {
                final r = state.reviews[index];
                return ReviewListItem(review: r);
              },
            ),
          ),
        ],
      ),
    );
  }
}
