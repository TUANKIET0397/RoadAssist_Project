import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:road_assist/ui/garage/home/viewmodel/garage_home_viewmodel.dart'
    as vm;
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_viewmodel.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';
import 'package:road_assist/ui/garage/home/viewmodel/garage_home_viewmodel.dart';
import 'package:road_assist/ui/garage/home/widgets/rescue_request_card.dart';
import 'package:road_assist/ui/user/account/widgets/logout_button.dart';

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

    print(
      ' Building garage home with location: ${location.lat}, ${location.lng}',
    );

    // Tạo locationMap một lần
    final locationMap = {
      'lat': location.lat,
      'lng': location.lng,
      'radius': 10.0,
    };

    // Dùng mock provider nếu USE_MOCK_DATA = true
    // MockProvider trả về synchronous List, không cần .when()
    final requestList = USE_MOCK_DATA
        ? ref.watch(mockRescueRequestsProvider(locationMap))
        : ref.watch(pendingRescueRequestsProvider(locationMap)).valueOrNull ??
              [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh requests
              if (DISABLE_DISTANCE_FILTER) {
                ref.refresh(allPendingRescueRequestsProvider);
              } else {
                ref.refresh(pendingRescueRequestsProvider(locationMap));
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1e3a8a), Color(0xFF0f172a)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            USE_MOCK_DATA
                ? _buildListView(context, ref, requestList, locationMap)
                : ref
                      .watch(pendingRescueRequestsProvider(locationMap))
                      .when(
                        data: (list) {
                          print(
                            'Loaded ${list.length} rescue requests (real data)',
                          );
                          return _buildListView(
                            context,
                            ref,
                            list,
                            locationMap,
                          );
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(color: Colors.blue),
                        ),
                        error: (error, st) {
                          print(' Error: $error');
                          return Center(
                            child: Text(
                              'Lỗi: $error',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
            Positioned(
              top: 16,
              right: 16,
              child: LogoutButton(onTap: vm.logout),
            ),
          ],
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
    print('✅ Loaded ${requestList.length} rescue requests');
    if (requestList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.blue.shade400),
            const SizedBox(height: 16),
            Text(
              'Không có yêu cầu cứu hộ',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Chưa có yêu cầu cứu hộ nào gần vị trí của bạn',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.blue.shade300),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (DISABLE_DISTANCE_FILTER) {
          await ref.refresh(allPendingRescueRequestsProvider.future);
        } else {
          await ref.refresh(pendingRescueRequestsProvider(locationMap).future);
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
              context.push(
                '/garage/rescue-request-detail/${request.id}',
              );
            },
          );
        },
      ),
    );
  }
}
