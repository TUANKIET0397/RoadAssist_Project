import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:road_assist/data/datasources/local/vehicle_constants.dart';
import 'package:road_assist/data/models/completion_payload.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_viewmodel.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/completion_vm.dart';
import 'package:road_assist/ui/shared/widgets/rescue_progress_timeline.dart';

class UserRescueTrackingScreen extends ConsumerStatefulWidget {
  final String rescueRequestId;
  final String? garageId;

  const UserRescueTrackingScreen({
    super.key,
    required this.rescueRequestId,
    this.garageId,
  });

  @override
  ConsumerState<UserRescueTrackingScreen> createState() =>
      _UserRescueTrackingScreenState();
}

class _UserRescueTrackingScreenState
    extends ConsumerState<UserRescueTrackingScreen> {
  bool _hasNavigatedToCompletion = false;

  @override
  Widget build(BuildContext context) {
    final rescueRequest = ref.watch(
      currentRescueRequestProvider(widget.rescueRequestId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theo dõi cứu hộ'),
        centerTitle: true,
      ),
      body: rescueRequest.when(
        data: (request) {
          if (request == null) {
            return const Center(child: Text('Không tìm thấy yêu cầu'));
          }

          // 🎯 CHECK IF COMPLETED - auto navigate
          final isCompleted = request.status == 'completed' || request.progressStep >= 4;
          
          if (isCompleted && !_hasNavigatedToCompletion) {
            _hasNavigatedToCompletion = true;
            debugPrint('✅ [TrackingScreen] NAVIGATING TO COMPLETION');
            
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              
              final completedTime = request.completedAt ?? DateTime.now();
              
              final payload = CompletionPayload(
                title: 'Hoàn thành cứu hộ',
                subtitle: 'Cảm ơn bạn đã sử dụng RoadAssist',
                vehicleImage:
                    kVehicleImages[request.vehicleType] ??
                    'assets/images/illustrations/vehicle.png',
                vehicleName: request.vehicleType,
                vehicleModel: request.vehicleModel,
                issue: request.issues.join(', '),
                address: request.location,
                completedTime:
                    '${completedTime.hour}:${completedTime.minute.toString().padLeft(2, '0')} ${completedTime.day}/${completedTime.month}/${completedTime.year}',
                garageName: request.name ?? 'Garage',
                garageAvatar: 'assets/images/garage/default.png',
              );

              ref.read(completionProvider.notifier).setCompletion(payload);

              context.pushReplacement('/user/completion');
            });
          }

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0f172a), Color(0xFF1e3a8a)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Image.asset(  
                      'assets/images/illustrations/calendar_state.png',
                      height: 130,
                      width: 130,
                    ),
                   
                    const SizedBox(height: 10),

                    // Progress steps
                    RescueProgressTimeline(request: request),

                    const SizedBox(height: 15),

                    // Chat button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Navigate to chat screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Chat với garage'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Lỗi: $error'),
        ),
      ),
    );
  }
}
