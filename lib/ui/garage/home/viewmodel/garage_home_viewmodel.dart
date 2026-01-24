import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_viewmodel.dart';


Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
/// Toggle để switch giữa real và mock data
const bool USE_MOCK_DATA = false; // ← Change thành true để dùng mock data

/// Toggle để test UI khi không có rescue requests
const bool USE_EMPTY_MOCK_DATA = false; // ← Change thành true để test empty state

/// 🧪 TESTING: Tạm thời lấy TẤT CẢ pending requests (không filter khoảng cách)
const bool DISABLE_DISTANCE_FILTER = true; // ← Change thành false để bật filter khoảng cách lại

/// Provider chọn list requests theo mode (mock hoặc real)
final rescueRequestsProvider = FutureProvider.family.autoDispose<
    List<RescueRequestModel>,
    Map<String, double>>((ref, locationMap) async {
  if (USE_MOCK_DATA) {
    return ref.watch(mockRescueRequestsProvider(locationMap));
  } else if (DISABLE_DISTANCE_FILTER) {
    // 🧪 TESTING: Lấy tất cả pending requests không filter khoảng cách
    final asyncValue = ref.watch(allPendingRescueRequestsProvider);
    return asyncValue.when(
      data: (data) => data,
      loading: () => throw Exception('Loading...'),
      error: (error, stack) => throw Exception(error),
    );
  } else {
    final asyncValue = ref.watch(pendingRescueRequestsProvider(locationMap));
    return asyncValue.when(
      data: (data) => data,
      loading: () => throw Exception('Loading...'),
      error: (error, stack) => throw Exception(error),
    );
  }
});

/// Mock data provider - để test UI không cần database - dùng StateProvider (synchronous)
final mockRescueRequestsProvider = StateProvider.family.autoDispose<
    List<RescueRequestModel>,
    Map<String, double>>((ref, location) {
  // Nếu USE_EMPTY_MOCK_DATA = true, trả về danh sách rỗng
  if (USE_EMPTY_MOCK_DATA) {
    print('🧪 MOCK MODE: Trả về 0 mock requests (EMPTY TEST)');
    return [];
  }

  // Mock requests gần SF location
  final mockRequests = [
    RescueRequestModel(
      id: 'mock_1',
      userId: 'user_123',
      userName: 'Nguyễn Văn A',
      userPhone: '0901234567',
      vehicleType: 'Xe tay ga',
      vehicleModel: 'Honda SH Mode 2025',
      issues: ['Hết xăng', 'Bể lốp'],
      location: 'SF Downtown',
      latitude: 37.4219983,
      longitude: -122.084,
      imageUrl: null,
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      garageId: null,
      garageName: null,
      acceptedAt: null,
      completedAt: null,
      cancelledAt: null,
      progressStep: 0,
    ),
    RescueRequestModel(
      id: 'mock_2',
      userId: 'user_456',
      userName: 'Trần Thị B',
      userPhone: '0912345678',
      vehicleType: 'Xe số',
      vehicleModel: 'Honda Wave',
      issues: ['Mất chìa khóa'],
      location: 'SF Market St',
      latitude: 37.4219983,
      longitude: -122.084,
      imageUrl: null,
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      garageId: null,
      garageName: null,
      acceptedAt: null,
      completedAt: null,
      cancelledAt: null,
      progressStep: 0,
    ),
    RescueRequestModel(
      id: 'mock_3',
      userId: 'user_789',
      userName: 'Phạm Văn C',
      userPhone: '0923456789',
      vehicleType: 'Xe côn tay',
      vehicleModel: 'Yamaha Exciter',
      issues: ['Động cơ không nổ'],
      location: 'SF Union Square',
      latitude: 37.4219983,
      longitude: -122.084,
      imageUrl: null,
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      garageId: null,
      garageName: null,
      acceptedAt: null,
      completedAt: null,
      cancelledAt: null,
      progressStep: 0,
    ),
  ];

  print('🧪 MOCK MODE: Trả về ${mockRequests.length} mock requests');
  return mockRequests;
});

/// Mock current request provider - để detail screen dùng mock data
final mockCurrentRescueRequestProvider = StateProvider.family.autoDispose<
    RescueRequestModel?,
    String>((ref, requestId) {
  // Map mock request id to mock request
  final mockRequests = {
    'mock_1': RescueRequestModel(
      id: 'mock_1',
      userId: 'user_123',
      userName: 'Nguyễn Văn A',
      userPhone: '0901234567',
      vehicleType: 'Xe tay ga',
      vehicleModel: 'Honda SH Mode 2025',
      issues: ['Hết xăng', 'Bể lốp'],
      location: 'SF Downtown',
      latitude: 37.4219983,
      longitude: -122.084,
      imageUrl: null,
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      garageId: null,
      garageName: null,
      acceptedAt: null,
      completedAt: null,
      cancelledAt: null,
      progressStep: 0,
    ),
    'mock_2': RescueRequestModel(
      id: 'mock_2',
      userId: 'user_456',
      userName: 'Trần Thị B',
      userPhone: '0912345678',
      vehicleType: 'Xe số',
      vehicleModel: 'Honda Wave',
      issues: ['Mất chìa khóa'],
      location: 'SF Market St',
      latitude: 37.4219983,
      longitude: -122.084,
      imageUrl: null,
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      garageId: null,
      garageName: null,
      acceptedAt: null,
      completedAt: null,
      cancelledAt: null,
      progressStep: 0,
    ),
    'mock_3': RescueRequestModel(
      id: 'mock_3',
      userId: 'user_789',
      userName: 'Phạm Văn C',
      userPhone: '0923456789',
      vehicleType: 'Xe côn tay',
      vehicleModel: 'Yamaha Exciter',
      issues: ['Động cơ không nổ'],
      location: 'SF Union Square',
      latitude: 37.4219983,
      longitude: -122.084,
      imageUrl: null,
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      garageId: null,
      garageName: null,
      acceptedAt: null,
      completedAt: null,
      cancelledAt: null,
      progressStep: 0,
    ),
  };

  return mockRequests[requestId];
});
