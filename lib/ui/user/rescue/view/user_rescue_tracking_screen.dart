import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_viewmodel.dart';
import 'package:road_assist/ui/shared/widgets/rescue_progress_timeline.dart';

class UserRescueTrackingScreen extends ConsumerWidget {
  final String rescueRequestId;
  final String? garageId;

  const UserRescueTrackingScreen({
    super.key,
    required this.rescueRequestId,
    this.garageId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rescueRequest = ref.watch(
      currentRescueRequestProvider(rescueRequestId),
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
