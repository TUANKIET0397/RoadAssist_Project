import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/theme/app_palette.dart';
import 'package:road_assist/ui/user/garage/widget/garage_list_view.dart';

import '../viewmodel/garage_vm.dart';

class GarageListScreen extends ConsumerStatefulWidget {
  const GarageListScreen({super.key});

  @override
  ConsumerState<GarageListScreen> createState() => _GarageListScreenState();
}

class _GarageListScreenState extends ConsumerState<GarageListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(garageProvider.notifier).fetchGarages();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(garageProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(garageProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppPalette.bgColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            GarageHeader(title: 'Danh sách garage', onSearchTap: () {}),

            Expanded(
              child: GarageListView(
                garages: state.garages,
                isLoading: state.isLoading,
                isLoadingMore: state.isLoadingMore,
                controller: _scrollController,
              ),
            ),
            SizedBox(height: 80),
          ],
          // ),
        ),
      ),
    );
  }
}

class GarageHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSearchTap;

  const GarageHeader({super.key, required this.title, this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topPadding + 10, 16, 8),
      decoration: const BoxDecoration(color: Color.fromRGBO(37, 44, 59, 1)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFF34C8E8), Color(0xFF4E4AF2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 18),
              onPressed: onSearchTap,
            ),
          ),
        ],
      ),
    );
  }
}
