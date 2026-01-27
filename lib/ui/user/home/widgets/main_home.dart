import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:road_assist/ui/user/home/viewmodel/home_vehicle_provider.dart';
import 'package:road_assist/ui/user/home/widgets/big_vehicle_card.dart';
import 'package:road_assist/ui/user/home/widgets/feature_card.dart';
import 'package:road_assist/ui/user/home/widgets/vehicle_grid_item.dart';
import 'package:road_assist/ui/user/home/widgets/clipped_card.dart';
import 'package:road_assist/ui/user/home/clippers/rps_clipper_big.dart';

class MainHome extends ConsumerWidget {
  const MainHome({super.key});

  /// Navigate to rescue request screen with pre-selected vehicle type
  void _navigateWithVehicle(BuildContext context, WidgetRef ref, String? vehicleType) {
    if (vehicleType == null) return;
    ref.read(preSelectedVehicleTypeProvider.notifier).state = vehicleType;
    ref.read(preSelectedIssueProvider.notifier).state = null; // Clear issue
    context.push('/rescue-request');
  }

  /// Navigate to rescue request screen with pre-selected issue
  void _navigateWithIssue(BuildContext context, WidgetRef ref, String issue, List<String?> myVehicleTypes) {
    // Set first vehicle if available
    final firstVehicle = myVehicleTypes.whereType<String>().firstOrNull;
    if (firstVehicle != null) {
      ref.read(preSelectedVehicleTypeProvider.notifier).state = firstVehicle;
    } else {
      ref.read(preSelectedVehicleTypeProvider.notifier).state = null;
    }
    ref.read(preSelectedIssueProvider.notifier).state = issue;
    context.push('/rescue-request');
  }

  /// Map feature title to issue name
  String _mapFeatureToIssue(String featureTitle) {
    switch (featureTitle) {
      case 'Vận chuyển':
        return 'Vận chuyển xe';
      case 'Xăng dầu':
        return 'Hết xăng';
      case 'Không rõ':
        return 'Không rõ nguyên nhân';
      case 'Máy móc':
        return 'Hư máy';
      case 'Chìa khóa':
        return 'Mất chìa khóa';
      default:
        return featureTitle;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch vehicle providers
    final myVehiclesAsync = ref.watch(myVehiclesProvider);
    final otherVehiclesAsync = ref.watch(otherVehiclesProvider);
    
    // Get list of user's registered vehicle types for feature card navigation
    final myVehicleTypes = myVehiclesAsync.whenOrNull(
      data: (vehicles) => vehicles.map((v) => v.vehicleType).toList(),
    ) ?? [];

    return ListView(
      children: [
        /// ================= BIG CARD =================
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            return Transform.translate(
              offset: const Offset(0, -35),
              child: Center(
                child: ClippedCard(
                  width: width,
                  heightFactor: 1,
                  clipper: RPSClipperBig(),
                  child: const BigVehicleCardContent(recuerequest: null),
                ),
              ),
            );
          },
        ),

        /// ================= FEATURE ICONS =================
        LayoutBuilder(
          builder: (context, constraints) {
            final spacing = constraints.maxWidth * 0.03;
            final features = [
              {'icon': 'assets/images/icons/transport.png', 'title': 'Vận chuyển'},
              {'icon': 'assets/images/icons/gas.png', 'title': 'Xăng dầu'},
              {'icon': 'assets/images/icons/warning.png', 'title': 'Không rõ'},
              {'icon': 'assets/images/icons/setting.png', 'title': 'Máy móc'},
              {'icon': 'assets/images/icons/key.png', 'title': 'Chìa khóa'},
            ];

            return Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: features.map((feature) {
                    return FeatureCard(
                      icon: feature['icon']!,
                      title: feature['title']!,
                      onTap: () {
                        final issue = _mapFeatureToIssue(feature['title']!);
                        _navigateWithIssue(context, ref, issue, myVehicleTypes);
                      },
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),

        /// ================= TITLE =================
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Phương tiện của tôi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        /// ================= MY VEHICLES GRID =================
        myVehiclesAsync.when(
          data: (myVehicles) {
            if (myVehicles.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Bạn chưa đăng ký xe nào',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 0,
                  childAspectRatio: 0.8,
                ),
                itemCount: myVehicles.length,
                itemBuilder: (context, index) {
                  final item = myVehicles[index];
                  return VehicleGridItem(
                    title: item.title,
                    subtitle1: item.subtitle1,
                    subtitle2: item.subtitle2,
                    image: item.image,
                    isFavorite: item.isFavorite,
                    onFavoriteTap: () {},
                    onTap: () => _navigateWithVehicle(context, ref, item.vehicleType),
                  );
                },
              ),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Lỗi tải xe: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),

        /// ================= TITLE =================
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Phương tiện khác',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        /// ================= OTHER VEHICLES GRID =================
        otherVehiclesAsync.when(
          data: (otherVehicles) {
            if (otherVehicles.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Tất cả xe đã được đăng ký',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 0,
                  childAspectRatio: 0.8,
                ),
                itemCount: otherVehicles.length,
                itemBuilder: (context, index) {
                  final item = otherVehicles[index];
                  return VehicleGridItem(
                    title: item.title,
                    subtitle1: item.subtitle1,
                    subtitle2: item.subtitle2,
                    image: item.image,
                    isFavorite: item.isFavorite,
                    onFavoriteTap: () {},
                    onTap: () => _navigateWithVehicle(context, ref, item.vehicleType),
                  );
                },
              ),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Lỗi tải xe: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
        const SizedBox(height: 110),
      ],
    );
  }
}
