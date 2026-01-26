import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:road_assist/core/providers/garage_notification_provider.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';
import 'package:road_assist/ui/garage/home/widgets/rescue_request_card.dart';
import 'package:road_assist/core/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GarageHomeScreen extends ConsumerStatefulWidget {
  final Function(String)? onSelectRequest;

  const GarageHomeScreen({super.key, this.onSelectRequest});

  @override
  ConsumerState<GarageHomeScreen> createState() => _GarageHomeScreenState();
}

class _GarageHomeScreenState extends ConsumerState<GarageHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Cleanup expired notifications khi vào garage home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authStateProvider);
      if (authState.userId != null) {
        // Comment cleanup tạm thời vì thiếu Firestore index
        // ref.read(notificationActionProvider).cleanupExpiredNotifications(authState.userId!);
      }
      debugPrint('Garage Home initialized with notification cleanup');
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final garageId = authState.userId;

    if (garageId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Lỗi: Không tìm thấy Garage ID'),
        ),
      );
    }

    debugPrint('Building garage home for garageId: $garageId');

    // Sử dụng StreamProvider trực tiếp để tự động cập nhật real-time
    final requestData = ref.watch(notifiedRescueRequestsProvider(garageId));

    // Lấy tên garage từ Firestore
    final garageName = ref.watch(_garageNameProvider(garageId));

    return Scaffold(
      appBar: AppBar(
        title: garageName.when(
          data: (name) => Text(name),
          loading: () => const Text('Garage'),
          error: (_, __) => const Text('Garage'),
        ),
        backgroundColor: const Color.fromARGB(255, 53, 53, 53),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh notifications (thủ công nếu cần)
              ref.invalidate(notifiedRescueRequestsProvider(garageId));
              debugPrint('Refreshed rescue request notifications');
            },
          ),
        ],
      ),
      body: requestData.when(
        data: (list) {
          // Có dữ liệu → DÙNG gradient
          return Container(
            decoration: list.isNotEmpty
                ? BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0f172a), Color(0xFF1e3a8a)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: list.isNotEmpty ? Colors.cyan : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        list.isNotEmpty 
                          ? 'Có ${list.length} yêu cầu cứu hộ mới'
                          : 'Chưa có yêu cầu cứu hộ nào',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: list.isNotEmpty ? Colors.white : Colors.grey.shade400,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildNotificationListView(context, ref, list, garageId),
                ),
              ],
            ),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.blue)),
        error: (error, _) => Center(
          child: Text(
            'Lỗi: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  static Widget _buildNotificationListView(
    BuildContext context,
    WidgetRef ref,
    List<RescueRequestModel> requestList,
    String garageId,
  ) {
    debugPrint(' Notification ListView: ${requestList.length} rescue requests');
    
    if (requestList.isEmpty) {
      return Stack(
        children: [
          // Ảnh nền nằm dưới
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/illustrations/no_rescue.png',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fitWidth, // giữ tỉ lệ, ăn full ngang
              opacity: const AlwaysStoppedAnimation<double>(0.3),
            ),
          ),

          // Nội dung nằm trên
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications_off,
                  color: Colors.grey.shade400,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có thông báo',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hệ thống sẽ tự động gửi yêu cầu cứu hộ\nphù hợp đến garage của bạn',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.blue.shade300),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Chỉ cần invalidate notifiedRescueRequestsProvider
        ref.invalidate(notifiedRescueRequestsProvider(garageId));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requestList.length,
        cacheExtent: 2000,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        itemBuilder: (context, index) {
          final request = requestList[index];
          return RescueRequestCard(
              request: request,
              onAccept: () {
                debugPrint(' onAccept callback triggered for request: ${request.id}');
                
                // Chỉ navigate đến detail, KHÔNG mark notification
                // Để khi back lại vẫn còn thấy request trong list
                if (context.mounted) {
                  debugPrint(' Navigating to: /garage/rescue-request-detail/${request.id}');
                  context.push('/garage/rescue-request-detail/${request.id}');
                }
              },
          );
        },
      ),
    );
  }
}

/// Provider để lấy tên garage từ Firestore
final _garageNameProvider = FutureProvider.family<String, String>((
  ref,
  garageId,
) async {
  try {
    final firestore = FirebaseFirestore.instance;
    final doc = await firestore.collection('garages').doc(garageId).get();

    if (doc.exists) {
      final name = doc.data()?['name'] as String? ?? 'Garage';
      return name;
    }
    return 'Garage';
  } catch (e) {
    print('Error fetching garage name: $e');
    return 'Garage';
  }
});
