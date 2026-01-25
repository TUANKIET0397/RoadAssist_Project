import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_viewmodel.dart';

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
                    // Garage info card
                    if (request.garageName != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade900.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.lightBlueAccent.withOpacity(0.2),
                                  ),
                                  child: const Icon(
                                    Icons.store,
                                    color: Colors.lightBlueAccent,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        request.garageName ?? 'Garage',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (request.garagePhone != null)
                                        Text(
                                          request.garagePhone ?? '',
                                          style: TextStyle(
                                            color: Colors.blue.shade200,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Progress steps
                    _buildProgressSteps(request),

                    const SizedBox(height: 32),

                    // Vehicle info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thông tin xe',
                            style: TextStyle(
                              color: Colors.blue.shade200,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.two_wheeler,
                                color: Colors.lightBlueAccent,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      request.vehicleType,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      request.vehicleModel,
                                      style: TextStyle(
                                        color: Colors.blue.shade200,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Location
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vị trí của bạn',
                            style: TextStyle(color: Colors.blue.shade200),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.lightBlueAccent,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  request.location,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

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

  Widget _buildProgressSteps(RescueRequestModel request) {
    final steps = [
      {
        'step': 1,
        'title': 'Garage đã nhận cứu hộ',
        'icon': Icons.check_circle,
        'completed': request.progressStep >= 1,
      },
      {
        'step': 2,
        'title': 'Garage đã đến nơi của bạn',
        'icon': Icons.location_on,
        'completed': request.progressStep >= 2,
      },
      {
        'step': 3,
        'title': 'Tiến hành sửa chữa',
        'icon': Icons.build,
        'completed': request.progressStep >= 3,
      },
      {
        'step': 4,
        'title': 'Hoàn thành cứu hộ',
        'icon': Icons.done_all,
        'completed': request.progressStep >= 4,
      },
    ];

    return Column(
      children: [
        for (int i = 0; i < steps.length; i++)
          Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: steps[i]['completed'] as bool
                          ? Colors.lightBlueAccent
                          : Colors.grey.shade700,
                    ),
                    child: Icon(
                      steps[i]['icon'] as IconData,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[i]['title'] as String,
                          style: TextStyle(
                            color: steps[i]['completed'] as bool
                                ? Colors.white
                                : Colors.grey.shade400,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (steps[i]['completed'] as bool) ...[
                          const SizedBox(height: 4),
                          Text(
                            _getStepTime(request, steps[i]['step'] as int),
                            style: TextStyle(
                              color: Colors.blue.shade200,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (i < steps.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 25, top: 8, bottom: 8),
                  child: Container(
                    width: 2,
                    height: 30,
                    color: steps[i + 1]['completed'] as bool
                        ? Colors.lightBlueAccent
                        : Colors.grey.shade700,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  String _getStepTime(RescueRequestModel request, int step) {
    DateTime? dateTime;
    switch (step) {
      case 1:
        dateTime = request.acceptedAt;
        break;
      case 2:
        dateTime = request.arrivedAt;
        break;
      case 3:
        dateTime = request.repairingStartedAt;
        break;
      case 4:
        dateTime = request.completedAt;
        break;
      default:
        return '';
    }

    if (dateTime == null) return '';

    // Format thời gian thực (HH:mm:ss)
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    final date = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');

    return '$date/$month lúc $hour:$minute:$second';
  }
}
