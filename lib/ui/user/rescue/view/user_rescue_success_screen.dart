import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:road_assist/ui/user/rescue/widgets/rescue_vehiclecard.dart';
import 'package:road_assist/data/datasources/local/vehicle_constants.dart';
import 'package:road_assist/ui/user/rescue/widgets/rescue_status_checklist.dart';
import 'package:road_assist/ui/user/rescue/widgets/rescue_location_card.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_viewmodel.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/completion_vm.dart';
import 'package:road_assist/data/models/completion_payload.dart';
import 'package:road_assist/ui/user/rescue/view/user_rescue_tracking_screen.dart';
import 'package:road_assist/ui/user/rescue/view/completion_screen.dart';
import 'package:road_assist/ui/user/rescue/widgets/rescue_cancel_button.dart';

class UserRescueSuccessScreen extends ConsumerStatefulWidget {
  final String rescueRequestId;
  final String? garageId;
  final String? garageName;
  final Function() onBack;

  const UserRescueSuccessScreen({
    super.key,
    required this.rescueRequestId,
    this.garageId,
    this.garageName,
    required this.onBack,
  });

  @override
  ConsumerState<UserRescueSuccessScreen> createState() =>
      _UserRescueSuccessScreenState();
}

class _UserRescueSuccessScreenState
    extends ConsumerState<UserRescueSuccessScreen> {
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleCancelRequest() async {
    setState(() => _isCancelling = true);

    try {
      final repo = ref.read(rescueRequestRepoProvider);
      final success =
          await repo.cancelRescueRequest(widget.rescueRequestId);

      if (success && mounted) {
        widget.onBack();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã hủy yêu cầu cứu hộ')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi hủy yêu cầu')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rescueRequest = ref.watch(
      currentRescueRequestProvider(widget.rescueRequestId),
    );

    return Scaffold(
      body: rescueRequest.when(
        data: (request) {
          if (request == null) {
            return const Center(child: Text('Không tìm thấy yêu cầu'));
          }

          // 🎯 CHECK IF COMPLETED - auto navigate
          if (request.status == 'completed' && request.completedAt != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final payload = CompletionPayload(
                title: 'Hoàn thành cứu hộ',
                subtitle: 'Cảm ơn bạn đã sử dụng RoadAssist',
                vehicleImage: kVehicleImages[request.vehicleType] ?? 'assets/images/illustrations/vehicle.png',
                vehicleName: request.vehicleType,
                vehicleModel: request.vehicleModel,
                issue: request.issues.join(', '),
                address: request.location,
                completedTime:
                    '${request.completedAt!.hour}:${request.completedAt!.minute.toString().padLeft(2, '0')} ${request.completedAt!.day}/${request.completedAt!.month}/${request.completedAt!.year}',
                garageName: request.name ?? 'Garage',
                garageAvatar: 'assets/images/garage/default.png',
              );

              ref.read(completionProvider.notifier).setCompletion(payload);

              context.pushReplacement('/user/completion');
            });
          }

          // Kiểm tra có thể hủy hay không
          // progressStep: 0 = pending, 1 = arrived, 2 = repairing, 3 = completed
          final canCancel = request.progressStep < 3;
          final cancelMessage = request.progressStep >= 3
              ? 'Xe đang được sửa chữa, không thể hủy yêu cầu'
              : null;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0f172a), Color(0xFF1e3a8a)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/illustrations/success_shield.png',
                          height: 145,
                          width: 135,
                        ),

                        Text(
                          'Gửi yêu cầu cứu hộ thành công',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 21,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Garage sẽ sớm liên hệ với bạn',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 15,
                              ),
                        ),

                        const SizedBox(height: 8),

                        /// Vehicle card
                        RescueVehicleCard(request: request),

                        const SizedBox(height: 15),

                        RescueStatusChecklist(
                          garageName: request.name ?? 'Garage',
                        ),

                        const SizedBox(height: 15),

                        /// Location
                        RescueLocationCard(
                          location: request.location,
                          userPhone: request.userPhone,
                        ),

                        const SizedBox(height: 24),

                        /// Primary button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UserRescueTrackingScreen(
                                        rescueRequestId: request.id,
                                        garageId: request.garageId,
                                      ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Theo dõi trạng thái cứu hộ'),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// Cancel button
                        RescueCancelButton(
                          enabled: canCancel,
                          disabledMessage: cancelMessage,
                          onConfirmCancel: _isCancelling
                              ? () {}
                              : _handleCancelRequest,
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  // Back button
                  Positioned(
                    top: 0,
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        widget.onBack();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
      ),
    );
  }
}
