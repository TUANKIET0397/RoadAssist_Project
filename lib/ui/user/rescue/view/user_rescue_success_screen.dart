import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_viewmodel.dart';

class UserRescueSuccessScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final rescueRequest =
        ref.watch(currentRescueRequestProvider(rescueRequestId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Garage đã nhận'),
        centerTitle: true,
        leading: SizedBox.shrink(),
      ),
      body: rescueRequest.when(
        data: (request) {
          if (request == null) {
            return const Center(
              child: Text('Không tìm thấy yêu cầu'),
            );
          }

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1e3a8a),
                  Color(0xFF0f172a),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.shade600.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.green.shade400,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green.shade400,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Gửi yêu cầu cứu hộ thành công!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Garage đã nhận yêu cầu của bạn và sẽ liên hệ sớm',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue.shade200,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Garage info
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.blue.shade900.withOpacity(0.5),
                        border: Border.all(
                          color: Colors.blue.shade400,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Garage đã nhận',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue.shade300,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue.shade600,
                                ),
                                child: const Icon(
                                  Icons.business,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      request.garageName ?? garageName ?? 'Đang tải...',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Garage cứu hộ xe',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.blue.shade300,
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
                    const SizedBox(height: 32),
                    // Request details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.blue.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.blue.shade400.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chi tiết yêu cầu',
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            context,
                            'Loại xe',
                            request.vehicleType,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            context,
                            'Model',
                            request.vehicleModel,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            context,
                            'Vấn đề',
                            request.issues.join(', '),
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            context,
                            'Vị trí',
                            request.location,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Back button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          onBack();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Quay lại',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.blue.shade300,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
