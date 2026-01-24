import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';
import 'package:road_assist/ui/navigation/viewmodel/rescue_navigation_provider.dart';

class BigVehicleCardContent extends ConsumerWidget {
  final RescueRequestModel? recuerequest;

  const BigVehicleCardContent({super.key, required this.recuerequest});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedRescueProvider.notifier).state = recuerequest;
        context.push('/rescue-request');
      },
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 42),
            child: Image.asset(
              'assets/images/illustrations/vehicle.png',
              width: 260,
            ),
          ),
          Positioned(
            bottom: 15,
            left: 32,
            child: Transform.rotate(
              angle: -0.1,
              child: const Text(
                'Báo Cáo Sự Cố',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
