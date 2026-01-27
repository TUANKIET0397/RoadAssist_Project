import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/garage_model.dart';
import 'package:road_assist/ui/shared/skeleton/skeleton_widgets.dart';

import 'garage_card.dart';

class GarageListView extends ConsumerWidget {
  final List<GarageModel> garages;
  final bool isLoading;
  final bool isLoadingMore;
  final ScrollController controller;

  const GarageListView({
    super.key,
    required this.garages,
    required this.isLoading,
    required this.isLoadingMore,
    required this.controller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading && garages.isEmpty) {
      return ListView.builder(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: 5,
        itemBuilder: (context, index) => const SkeletonGarageCard(),
      );
    }

    if (garages.isEmpty) {
      return const Center(
        child: Text(
          'Không có garage nào',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: garages.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= garages.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return GarageCard(garage: garages[index]);
      },
    );
  }
}
