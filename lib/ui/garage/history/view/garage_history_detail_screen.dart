import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/theme/app_palette.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_viewmodel.dart';
import 'package:road_assist/ui/garage/history/model/garage_history_item.dart';
import 'package:road_assist/ui/shared/widgets/rescue_progress_timeline.dart';
import 'package:road_assist/ui/shared/widgets/view_history_button.dart';
import 'package:road_assist/ui/user/chat/viewmodel/chatList_vm.dart';
import 'package:road_assist/ui/user/chat/view/chatGarage_screen.dart';
import 'package:road_assist/core/providers/auth_provider.dart';

class GarageHistoryDetailScreen extends ConsumerStatefulWidget {
  final GarageHistoryItem historyItem;

  const GarageHistoryDetailScreen({super.key, required this.historyItem});

  @override
  ConsumerState<GarageHistoryDetailScreen> createState() =>
      _GarageHistoryDetailScreenState();
}

class _GarageHistoryDetailScreenState
    extends ConsumerState<GarageHistoryDetailScreen> {
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
                    colors: AppPalette.bgColors,
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
                colors: AppPalette.bgColors,
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
            // Vehicle info
            _buildSection(
              title: 'Thông tin phương tiện',
              children: [
                _buildStatusRow(request),
                _buildInfoRow('Loại xe', request.vehicleType),
                _buildInfoRow('Mẫu xe', request.vehicleModel),
                _buildInfoRow('Các vấn đề', request.issues.join(', ')),
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

            RescueProgressTimeline(request: request, showBorder: true),

            const SizedBox(height: 20),

            // Contact user button
            ViewHistoryButton(
              text: 'Liên hệ với người dùng',
              icon: Icons.chat,
              onPressed: () => _contactUser(context, ref, request),
            ),

            // Timeline
            const SizedBox(height: 200),
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

  Future<void> _contactUser(
    BuildContext context,
    WidgetRef ref,
    RescueRequestModel request,
  ) async {
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
          MaterialPageRoute(builder: (_) => ChatScreen(chatId: chatId)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi kết nối: $e')));
      }
    }
  }

  Widget _buildStatusRow(RescueRequestModel request) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trạng thái',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const Spacer(),
          Text(
            request.status == 'completed' ? '✓ Hoàn thành' : '✕ Đã hủy',
            style: TextStyle(
              color: request.status == 'completed' ? Colors.green : Colors.red,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
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
            style: const TextStyle(color: Colors.white70, fontSize: 16),
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
