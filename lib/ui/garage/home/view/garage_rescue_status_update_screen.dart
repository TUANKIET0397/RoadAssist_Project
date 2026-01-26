import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';
import 'package:road_assist/data/datasources/remote/rescue_service.dart';
import 'package:road_assist/ui/garage/home/viewmodel/garage_completion_vm.dart';
import 'package:road_assist/data/models/garage_completion_payload.dart';
import 'package:road_assist/ui/garage/home/view/garage_completion_screen.dart';
import 'package:road_assist/data/datasources/local/vehicle_constants.dart';
import 'package:road_assist/ui/user/chat/viewmodel/chatList_vm.dart';
import 'package:road_assist/core/providers/auth_provider.dart';
import 'package:road_assist/ui/user/chat/view/chatGarage_screen.dart';

// Provider để watch rescue request real-time
final currentGarageRescueRequestProvider =
    StreamProvider.family<RescueRequestModel?, String>((ref, rescueRequestId) {
      final rescueService = RescueService();
      return rescueService.watchRescueRequest(rescueRequestId).asyncMap((data) {
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

  static Future<void> _contactUser(BuildContext context, WidgetRef ref, RescueRequestModel request) async {
    try {
      final garageId = ref.read(userIdProvider); // Current garage ID
      if (garageId == null) return;
      
      final chatRepo = ref.read(chatRepositoryProvider);
      final chatId = await chatRepo.getOrCreateChat(
        userId: request.userId,
        garageId: garageId,
      );
      
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(chatId: chatId),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi kết nối: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch real-time updates
    final requestStream = ref.watch(
      currentGarageRescueRequestProvider(rescueRequestId),
    );

    return requestStream.when(
      data: (request) {
        if (request == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Cập nhật trạng thái cứu hộ')),
            body: const Center(child: Text('Không tìm thấy yêu cầu')),
          );
        }

        // Kiểm tra nếu hoàn thành hết (progressStep = 4)
        if (request.progressStep >= 4 && request.status == 'completed') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final payload = GarageCompletionPayload(
              title: 'Hoàn thành cứu hộ',
              subtitle: 'Cảm ơn bạn đã sử dụng RoadAssist',
              vehicleImage: kVehicleImages[request.vehicleType] ?? 'assets/images/illustrations/vehicle.png',
              vehicleName: request.vehicleType,
              vehicleModel: request.vehicleModel,
              issue: request.issues.join(', '),
              address: request.location,
              completedTime:
                  '${request.completedAt!.hour}:${request.completedAt!.minute.toString().padLeft(2, '0')} ${request.completedAt!.day}/${request.completedAt!.month}/${request.completedAt!.year}',
              userName: request.userName,
              userPhone: request.userPhone,
            );

            ref.read(garageCompletionProvider.notifier).setCompletion(payload);

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const GarageCompletionScreen(),
              ),
            );
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
                        color: Color(0xFF19253B),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ===== USER INFO =====
                          Row(
                            children: [
                              Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.lightBlueAccent.withValues(
                                    alpha: 0.2,
                                  ),
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
                                        fontSize: 20,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          request.userPhone,
                                          style: TextStyle(
                                            color: Colors.blue.shade200,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(
                                          Icons.call,
                                          size: 16,
                                          color: const Color.fromARGB(
                                            255,
                                            0,
                                            171,
                                            20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // ===== DIVIDER (tách 2 section) =====
                          Divider(
                            color: Colors.white.withValues(alpha: 0.15),
                            thickness: 1,
                          ),

                          // ===== VEHICLE INFO =====
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: request.vehicleType,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                TextSpan(
                                  text: ' (${request.vehicleModel})',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            '${request.issues.join(', ')}.',
                            style: TextStyle(
                              color: Colors.blueGrey.shade200,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => _contactUser(context, ref, request),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.lightBlueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text('Chat với khách hàng'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(onPressed: (){}, child: const Text('Gọi khách hàng')),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(onPressed: (){}, child: const Text('Xem vị trí khách hàng')),
                        ],
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
        for (int i = 0; i < steps.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TIMELINE
              Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: request.progressStep >= (steps[i]['step'] as int)
                          ? Colors.greenAccent
                          : Colors.blueAccent,
                      boxShadow: [
                        if (request.progressStep >= (steps[i]['step'] as int))
                          BoxShadow(
                            color: Colors.greenAccent.withValues(alpha: 0.8),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: Icon(
                      steps[i]['icon'] as IconData,
                      color: Colors.black,
                    ),
                  ),
                  if (i < steps.length - 1)
                    Container(
                      width: 2,
                      height: 40,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 12),

              // CONTENT
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade900.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[i]['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStepTime(request, steps[i]['step'] as int),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
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

    // Format thời gian thực (HH:ss)
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    final date = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');

    return '$date/$month lúc $hour:$minute:$second';
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
