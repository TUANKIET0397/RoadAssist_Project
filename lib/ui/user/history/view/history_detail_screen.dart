import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_viewmodel.dart';
import 'package:road_assist/ui/user/history/model/history_item.dart';
import 'package:road_assist/ui/shared/widgets/rescue_progress_timeline.dart';
import 'package:road_assist/ui/shared/widgets/view_history_button.dart';
import 'package:road_assist/ui/user/chat/viewmodel/chatList_vm.dart';
import 'package:road_assist/ui/user/chat/view/chatGarage_screen.dart';
import 'package:road_assist/core/providers/auth_provider.dart';

class HistoryDetailScreen extends ConsumerStatefulWidget {
  final HistoryItem historyItem;

  const HistoryDetailScreen({super.key, required this.historyItem});

  @override
  ConsumerState<HistoryDetailScreen> createState() =>
      _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends ConsumerState<HistoryDetailScreen> {
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

            // Garage info
            _buildSection(
              title: 'Thông tin garage',
              children: [
                _buildInfoRow('Tên garage', request.name ?? 'N/A'),
                _buildInfoRow('SĐT', request.garagePhone ?? 'N/A'),
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

            // Timeline progress
            RescueProgressTimeline(request: request, showBorder: true),
            
            const SizedBox(height: 20),
            
            // Contact garage button
            if (request.garageId != null)
              ViewHistoryButton(
                text: 'Liên hệ với garage',
                icon: Icons.chat,
                onPressed: () => _contactGarage(context, ref, request),
              ),

            const SizedBox(height: 200),

          ],
        ),
      ),
    );
  }

  Future<void> _contactGarage(BuildContext context, WidgetRef ref, RescueRequestModel request) async {
    if (request.garageId == null) return;
    
    try {
      final userId = ref.read(userIdProvider);
      if (userId == null) return;
      
      final chatRepo = ref.read(chatRepositoryProvider);
      final chatId = await chatRepo.getOrCreateChat(
        userId: userId,
        garageId: request.garageId!,
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
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
