import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/completion_payload.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';
import 'package:road_assist/ui/user/home/models/vehicle_model.dart';
import 'package:road_assist/ui/user/home/widgets/big_vehicle_card.dart';
import 'package:road_assist/ui/user/home/widgets/feature_card.dart';
import 'package:road_assist/ui/user/home/widgets/vehicle_favorite_grid.dart';
import 'package:road_assist/ui/user/home/widgets/vehicle_grid_item.dart';
import 'package:road_assist/ui/user/home/widgets/clipped_card.dart';
import 'package:road_assist/ui/user/home/clippers/rps_clipper_big.dart';
import 'package:road_assist/ui/user/rescue/view/completion_screen.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/completion_vm.dart';

class MainHome extends ConsumerWidget {
  const MainHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

            return Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    FeatureCard(
                      icon: 'assets/images/icons/transport.png',
                      title: 'Vận chuyển',
                    ),
                    FeatureCard(
                      icon: 'assets/images/icons/gas.png',
                      title: 'Xăng dầu',
                    ),
                    FeatureCard(
                      icon: 'assets/images/icons/warning.png',
                      title: 'Không rõ',
                    ),
                    FeatureCard(
                      icon: 'assets/images/icons/setting.png',
                      title: 'Máy móc',
                    ),
                    FeatureCard(
                      icon: 'assets/images/icons/key.png',
                      title: 'Chìa khóa',
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        /// ================= TITLE =================
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Phương tiện của bạn',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        /// ================= GRID =================
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16),
        //   child: GridView.builder(
        //     shrinkWrap: true,
        //     physics: const NeverScrollableScrollPhysics(),
        //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //       crossAxisCount: 2,
        //       crossAxisSpacing: 6,
        //       mainAxisSpacing: 0,
        //       childAspectRatio: 0.8,
        //     ),
        //     itemCount: vehicleGridData.length,
        //     itemBuilder: (context, index) {
        //       final item = vehicleGridData[index];
        //       return VehicleGridItem(
        //         title: item.title,
        //         subtitle1: item.subtitle1,
        //         subtitle2: item.subtitle2,
        //         image: item.image,
        //       );
        //     },
        //   ),
        // ),
        VehicleFavoriteGrid(),

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

        /// ================= GRID =================
        Padding(
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
            itemCount: 2,
            itemBuilder: (context, index) {
              return VehicleGridItem(
                title: 'hello',
                subtitle1: 'xin chao',
                subtitle2: 'tnKiet',
                image: 'assets/images/illustrations/XeContainer.png',
                isFavorite: false,
                onFavoriteTap: () {},
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('DEV: Test Completion'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              ref
                  .read(completionProvider.notifier)
                  .setCompletion(
                    CompletionPayload(
                      title: 'Hoàn thành cứu hộ',
                      subtitle: 'Cảm ơn bạn đã sử dụng RoadAssist',
                      vehicleImage: 'assets/images/illustrations/vehicle.png',
                      vehicleName: 'Xe tay ga',
                      vehicleModel: 'Honda SH Mode 2025',
                      issue: 'Bể lốp, hư máy',
                      address: '15B Nguyễn Lương Bằng, P25, TP HCM',
                      completedTime: '19:00 08-01-2026',
                      garageName: 'Minh Thuan Motor',
                      garageAvatar: 'assets/images/illustrations/vehicle.png',
                    ),
                  );

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CompletionScreen()),
              );
            },
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}
