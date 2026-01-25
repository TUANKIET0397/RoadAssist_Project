import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_viewmodel.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';
import 'package:road_assist/ui/garage/home/viewmodel/garage_home_viewmodel.dart';
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
    // Xóa cache khi vào garage home để lấy realtime data mới nhất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationMap = {'lat': 37.4219983, 'lng': -122.084, 'radius': 10.0};
      ref.invalidate(pendingRescueRequestsProvider);
      ref.invalidate(mockRescueRequestsProvider(locationMap));
      print(' Cache pending rescue requests đã được xóa khi vào Garage Home');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Fixed location (mock) - KHÔNG trigger rebuild
    final location = (lat: 37.4219983, lng: -122.084);
    final authState = ref.watch(authStateProvider);
    final garageId = authState.userId;

    print(
      ' Building garage home with location: ${location.lat}, ${location.lng}',
    );

    // Tạo locationMap một lần
    final locationMap = {
      'lat': location.lat,
      'lng': location.lng,
      'radius': 10.0,
    };

    // TESTING: Dùng allPendingRescueRequestsProvider (không filter khoảng cách)
    final requestData = DISABLE_DISTANCE_FILTER
        ? ref.watch(allPendingRescueRequestsProvider)
        : ref.watch(pendingRescueRequestsProvider(locationMap));

    // Lấy tên garage từ Firestore
    final garageName = garageId != null
        ? ref.watch(_garageNameProvider(garageId))
        : const AsyncValue.data('Garage');

    return Scaffold(
      appBar: AppBar(
        title: garageName.when(
          data: (name) => Text(name),
          loading: () => const Text('...'),
          error: (_, __) => const Text('Garage'),
        ),
        backgroundColor: Color.fromARGB(255, 53, 53, 53),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh requests

              if (DISABLE_DISTANCE_FILTER) {
                ref.invalidate(allPendingRescueRequestsProvider);
              } else {
                ref.invalidate(pendingRescueRequestsProvider(locationMap));
              }
            },
          ),
        ],
      ),
      body: requestData.when(
        data: (list) {
          // ✅ Có dữ liệu → DÙNG gradient
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
                  child: Text(
                    'Yêu cầu cứu hộ gần đây',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildListView(context, ref, list, locationMap),
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

  static Widget _buildListView(
    BuildContext context,
    WidgetRef ref,
    List<RescueRequestModel> requestList,
    Map<String, double> locationMap,
  ) {
    print('Loaded ${requestList.length} rescue requests');
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
                Text(
                  'Không có yêu cầu cứu hộ',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chưa có yêu cầu cứu hộ nào gần vị trí của bạn',
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
        if (DISABLE_DISTANCE_FILTER) {
          ref.invalidate(allPendingRescueRequestsProvider);
        } else {
          ref.invalidate(pendingRescueRequestsProvider(locationMap));
        }
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
              context.push('/garage/rescue-request-detail/${request.id}');
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
