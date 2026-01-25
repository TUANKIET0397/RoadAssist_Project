import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/theme/app_palette.dart';
import 'package:road_assist/ui/user/garage/widget/garage_list_view.dart';

import '../viewmodel/garage_vm.dart';

class GarageFavouriteScreen extends ConsumerWidget {
  const GarageFavouriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(garageProvider);

    final favouriteGarages =
    state.garages.where((g) => g.isFavorite).toList();

    return Container(
      decoration:
      BoxDecoration(
        gradient: LinearGradient(
          colors: AppPalette.bgColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          GarageHeader(title: 'Garage yêu thích'),

          Expanded(
            child: SafeArea(
              top: false,
              child: GarageListView(
                garages: favouriteGarages,
                isLoading: state.isLoading,
                isLoadingMore: false,
                controller: ScrollController(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class GarageHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSearchTap;

  const GarageHeader({
    super.key,
    required this.title,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(37, 44, 59, 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// TITLE
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          /// SEARCH BUTTON
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF34C8E8),
                  Color(0xFF4E4AF2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.white,
                size: 18,
              ),
              onPressed: onSearchTap,
            ),
          ),
        ],
      ),
    );
  }
}

