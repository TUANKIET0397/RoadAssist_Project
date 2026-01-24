import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/vehicle_grid_provider.dart';
import 'vehicle_grid_item.dart';

class VehicleFavoriteGrid extends ConsumerWidget {
  const VehicleFavoriteGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehicleGridProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: vehicles.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 6,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final item = vehicles[index];

          return VehicleGridItem(
            title: item.title,
            subtitle1: item.subtitle1,
            subtitle2: item.subtitle2,
            image: item.image,
            isFavorite: item.isFavorite,
            onFavoriteTap: () {
              ref.read(vehicleGridProvider.notifier).toggleFavorite(index);
            },
          );
        },
      ),
    );
  }
}
