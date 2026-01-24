import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';
import 'package:road_assist/data/datasources/remote/rescue_service.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_viewmodel.dart';

// Provider để watch rescue request real-time
final currentGarageRescueRequestProvider =
    StreamProvider.family<RescueRequestModel?, String>((ref, rescueRequestId) {
  final rescueService = RescueService();
  return rescueService
      .watchRescueRequest(rescueRequestId)
      .asyncMap((data) {
    if (data == null) return null;
    return RescueRequestModel.fromMap(rescueRequestId, data);
  });
});

// Provider để quản lý update trạng thái
final garageUpdateRescueProvider =
    StateNotifierProvider<GarageUpdateNotifier, AsyncValue<void>>((ref) {
  return GarageUpdateNotifier();
});

class GarageUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  GarageUpdateNotifier() : super(const AsyncValue.data(null));

  Future<void> updateRescueProgress(
    String rescueRequestId,
    int progressStep,
  ) async {
    state = const AsyncValue.loading();
    try {
      final rescueService = RescueService();
      await rescueService.updateRescueProgress(rescueRequestId, progressStep);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

class GarageRescueStatusUpdateScreen extends ConsumerWidget {
  final String rescueRequestId;
  final RescueRequestModel initialRequest;

  const GarageRescueStatusUpdateScreen({
    super.key,
    required this.rescueRequestId,
    required RescueRequestModel request,
  }) : initialRequest = request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch real-time updates
    final requestStream = ref.watch(currentGarageRescueRequestProvider(rescueRequestId));

    return requestStream.when(
      data: (request) {
        if (request == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Cập nhật trạng thái cứu hộ')),
            body: const Center(child: Text('Không tìm thấy yêu cầu')),
          );
        }

        // Kiểm tra nếu hoàn thành hết (progressStep = 4)
        if (request.progressStep >= 4) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop();
            // TODO: Navigate to history screen
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => GarageRescueHistoryScreen(),
            //   ),
            // );
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Cập nhật trạng thái cứu hộ'),
            centerTitle: true,
          ),
          body: Container(
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
                    // User info card
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
                                  Icons.person,
                                  color: Colors.lightBlueAccent,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      request.userName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      request.userPhone,
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
                          const SizedBox(height: 12),
                          Text(
                            request.location,
                            style: TextStyle(
                              color: Colors.blue.shade200,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

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
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: request.issues
                                .map(
                                  (issue) => Chip(
                                    backgroundColor:
                                        Colors.blueAccent.withOpacity(0.2),
                                    label: Text(
                                      issue,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Progress steps with action buttons
                    _buildProgressStatusUpdateButtons(context, ref, request),

                    const SizedBox(height: 32),

                    // Cập nhật button
                    if (request.progressStep < 4)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            _updateProgressStep(
                              context,
                              ref,
                              request.progressStep + 1,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Cập nhật trạng thái cứu hộ'),
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
                        child: const Text('Chat với khách hàng'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Cập nhật trạng thái cứu hộ')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, st) => Scaffold(
        appBar: AppBar(title: const Text('Cập nhật trạng thái cứu hộ')),
        body: Center(child: Text('Lỗi: $error')),
      ),
    );
  }

  Widget _buildProgressStatusUpdateButtons(
    BuildContext context,
    WidgetRef ref,
    RescueRequestModel request,
  ) {
    final steps = [
      {
        'step': 1,
        'title': 'Garage đã nhận cứu hộ',
        'icon': Icons.check_circle,
        'color': Colors.blue,
      },
      {
        'step': 2,
        'title': 'Garage đã đến nơi của bạn',
        'icon': Icons.location_on,
        'color': Colors.purple,
      },
      {
        'step': 3,
        'title': 'Tiến hành sửa chữa',
        'icon': Icons.build,
        'color': Colors.orange,
      },
      {
        'step': 4,
        'title': 'Hoàn thành cứu hộ',
        'icon': Icons.done_all,
        'color': Colors.green,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trạng thái cứu hộ',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < steps.length; i++)
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: request.progressStep >= (steps[i]['step'] as int)
                      ? (steps[i]['color'] as Color).withOpacity(0.3)
                      : Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: request.progressStep >= (steps[i]['step'] as int)
                        ? (steps[i]['color'] as Color)
                        : Colors.grey.shade700,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: request.progressStep >= (steps[i]['step'] as int)
                            ? (steps[i]['color'] as Color)
                            : Colors.grey.shade700,
                      ),
                      child: Icon(
                        steps[i]['icon'] as IconData,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            steps[i]['title'] as String,
                            style: TextStyle(
                              color: request.progressStep >= (steps[i]['step'] as int)
                                  ? Colors.white
                                  : Colors.grey.shade400,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (request.progressStep >= (steps[i]['step'] as int))
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '✓ ${_getStepTime(request, steps[i]['step'] as int)}',
                                style: TextStyle(
                                  color: steps[i]['color'] as Color,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (i < steps.length - 1) const SizedBox(height: 12),
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

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _updateProgressStep(BuildContext context, WidgetRef ref, int step) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.blue.shade900,
        title: const Text(
          'Xác nhận cập nhật',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Bạn có chắc chắn muốn cập nhật bước này?',
          style: TextStyle(color: Colors.blue.shade200),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              
              try {
                // Update progressStep
                await ref
                    .read(garageUpdateRescueProvider.notifier)
                    .updateRescueProgress(rescueRequestId, step);
                
                // Show success message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã cập nhật bước $step'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}
