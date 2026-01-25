import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_viewmodel.dart';
import 'package:road_assist/ui/garage/history/model/garage_history_item.dart';
import 'package:road_assist/ui/shared/widgets/rescue_progress_timeline.dart';

class GarageHistoryDetailScreen extends ConsumerStatefulWidget {
  final GarageHistoryItem historyItem;

  const GarageHistoryDetailScreen({
    super.key,
    required this.historyItem,
  });

  @override
  ConsumerState<GarageHistoryDetailScreen> createState() =>
      _GarageHistoryDetailScreenState();
}

class _GarageHistoryDetailScreenState extends ConsumerState<GarageHistoryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.historyItem.rescueRequestId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết lịch sử')),
        body: const Center(child: Text('Không có dữ liệu')),
      );
    }

    final rescueRequest = ref.watch(
      currentRescueRequestProvider(widget.historyItem.rescueRequestId!),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết cứu hộ'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0f172a),
      ),
      body: rescueRequest.when(
        data: (request) {
          if (request == null) {
            return Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Không tìm thấy yêu cầu',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          }

          return _buildContent(context, request);
        },
        loading: () => Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
        error: (error, st) {
          print('❌ Error loading rescue request: $error');
          print('Stack trace: $st');
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Text(
                  'Lỗi: $error',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
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
                color: const Color(0xFF001029),
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

            const SizedBox(height: 20),

            // Timeline progress
           

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

            // User info (thay vì garage info)
            _buildSection(
              title: 'Thông tin người dùng',
              children: [
                _buildInfoRow('Tên khách hàng', request.userName),
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

            RescueProgressTimeline(
              request: request,
              showBorder: true,
            ),
            // Timeline
           
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
        color: const Color(0xFF001029),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
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
              fontSize: 16,
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
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
