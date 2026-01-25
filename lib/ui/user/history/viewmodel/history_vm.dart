import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/user/history/model/history_item.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_viewmodel.dart';
import 'package:road_assist/core/providers/auth_provider.dart';

enum HistoryFilter { all, completed, cancelled }

final HistoryProvider = StateNotifierProvider<HistoryVM, HistoryFilter>((ref) {
  return HistoryVM();
});

class HistoryVM extends StateNotifier<HistoryFilter> {
  HistoryVM() : super(HistoryFilter.all);

  void setFilter(HistoryFilter filter) {
    state = filter;
  }
}

/// Provider lấy tất cả rescue requests của user từ Firebase
final userRescueHistoryProvider = StreamProvider.autoDispose<List<RescueRequestModel>>((ref) {
  final userId = ref.watch(userIdProvider);
  if (userId == null) return Stream.value([]);

  final repo = ref.watch(rescueRequestRepoProvider);
  return repo.getUserRequestsStream(userId);
});

/// Provider convert RescueRequestModel -> HistoryItem
final HistoryListProvider = Provider.autoDispose<AsyncValue<List<HistoryItem>>>((ref) {
  final filter = ref.watch(HistoryProvider);
  final rescueHistoryAsync = ref.watch(userRescueHistoryProvider);

  return rescueHistoryAsync.whenData((rescueList) {
    // Convert rescue requests to history items
    final historyItems = rescueList.map((rescue) {
      // Determine status based on rescue request status
      final status = rescue.status == 'completed' 
          ? Status.completed 
          : rescue.status == 'cancelled'
          ? Status.cancelled
          : Status.completed; // Default to completed for other statuses

      return HistoryItem(
        rescueRequestId: rescue.id,
        vehicleType: rescue.vehicleType,
        vehicleName: rescue.vehicleModel,
        vehicleModel: rescue.vehicleModel,
        image: 'assets/images/illustrations/vehicle.png',
        status: status,
        issue: rescue.issues.join(', '),
        address: rescue.location,
        completedTime: rescue.completedAt?.toString() ?? rescue.createdAt.toString(),
        garageName: rescue.name ?? 'Unknown Garage',
        userPhone: rescue.userPhone,
        latitude: rescue.latitude,
        longitude: rescue.longitude,
      );
    }).toList();

    // Filter based on selection
    switch (filter) {
      case HistoryFilter.completed:
        return historyItems.where((e) => e.status == Status.completed).toList();
      case HistoryFilter.cancelled:
        return historyItems.where((e) => e.status == Status.cancelled).toList();
      default:
        return historyItems;
    }
  });
});
