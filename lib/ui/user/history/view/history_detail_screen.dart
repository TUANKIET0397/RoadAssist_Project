import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_viewmodel.dart';
import 'package:road_assist/ui/user/history/model/history_item.dart';

class HistoryDetailScreen extends ConsumerWidget {
  final HistoryItem historyItem;

  const HistoryDetailScreen({
    super.key,
    required this.historyItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (historyItem.rescueRequestId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết lịch sử')),
        body: const Center(child: Text('Không có dữ liệu')),
      );
    }

    final rescueRequest = ref.watch(
      currentRescueRequestProvider(historyItem.rescueRequestId!),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết cứu hộ'),
        centerTitle: true,
      ),
      body: rescueRequest.when(
        data: (request) {
          if (request == null) {
            return const Center(child: Text('Không tìm thấy yêu cầu'));
          }

          return _buildContent(context, request);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, st) => Center(child: Text('Lỗi: $error')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, RescueRequestModel request) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF19253B),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Trạng thái',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: request.status == 'completed'
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                        ),
                        child: Text(
                          request.status == 'completed'
                              ? '✓ Hoàn thành'
                              : '✕ Đã hủy',
                          style: TextStyle(
                            color: request.status == 'completed'
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    request.vehicleModel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request.vehicleType,
                    style: TextStyle(
                      color: Colors.blue.shade200,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Vehicle info
            _buildSection(
              title: 'Thông tin phương tiện',
              children: [
                _buildInfoRow('Loại xe', request.vehicleType),
                _buildInfoRow('Mẫu xe', request.vehicleModel),
                _buildInfoRow(
                  'Các vấn đề',
                  request.issues.join(', '),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Garage info
            _buildSection(
              title: 'Thông tin garage',
              children: [
                _buildInfoRow('Tên garage', request.name ?? 'N/A'),
                _buildInfoRow('SĐT', request.userPhone),
              ],
            ),

            const SizedBox(height: 16),

            // Location info
            _buildSection(
              title: 'Vị trí cứu hộ',
              children: [
                _buildInfoRow('Địa chỉ', request.location),
                _buildInfoRow(
                  'Tọa độ',
                  '${request.latitude.toStringAsFixed(4)}, ${request.longitude.toStringAsFixed(4)}',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Timeline
            _buildTimeline(request),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF19253B),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(RescueRequestModel request) {
    final steps = [
      (
        'Yêu cầu được gửi',
        request.createdAt,
        request.progressStep >= 0,
      ),
      (
        'Garage đã nhận',
        request.acceptedAt,
        request.progressStep >= 1,
      ),
      (
        'Garage đã đến',
        request.arrivedAt,
        request.progressStep >= 1,
      ),
      (
        'Sửa chữa',
        request.repairingStartedAt,
        request.progressStep >= 2,
      ),
      (
        'Hoàn thành',
        request.completedAt,
        request.progressStep >= 3,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF19253B),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quá trình xử lý',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...steps
              .asMap()
              .entries
              .map(
                (entry) => _buildTimelineItem(
                  entry.value.$1,
                  entry.value.$2,
                  entry.value.$3,
                  isLast: entry.key == steps.length - 1,
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String label,
    DateTime? dateTime,
    bool isCompleted, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? Colors.green.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : Icons.pending,
                    size: 14,
                    color: isCompleted ? Colors.green : Colors.grey,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 32,
                    color: isCompleted
                        ? Colors.green.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.2),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isCompleted ? Colors.white : Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (dateTime != null)
                    Text(
                      '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
