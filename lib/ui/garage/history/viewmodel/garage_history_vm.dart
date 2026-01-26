import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/garage/history/model/garage_history_item.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_viewmodel.dart';
import 'package:road_assist/core/providers/auth_provider.dart';
import 'package:road_assist/data/datasources/local/vehicle_constants.dart';

enum GarageHistoryFilter { all, completed, cancelled }

final GarageHistoryProvider = StateNotifierProvider<GarageHistoryVM, GarageHistoryFilter>((ref) {
  return GarageHistoryVM();
});

class GarageHistoryVM extends StateNotifier<GarageHistoryFilter> {
  GarageHistoryVM() : super(GarageHistoryFilter.all);

  void setFilter(GarageHistoryFilter filter) {
    state = filter;
  }
}

/// Provider lấy tất cả rescue requests của garage từ Firebase
final garageRescueHistoryProvider = StreamProvider.autoDispose<List<RescueRequestModel>>((ref) {
  final garageId = ref.watch(userIdProvider);
  if (garageId == null) return Stream.value([]);

  final repo = ref.watch(rescueRequestRepoProvider);
  return repo.getGarageRequestsStream(garageId);
});

/// Provider convert RescueRequestModel -> GarageHistoryItem
final GarageHistoryListProvider = Provider.autoDispose<AsyncValue<List<GarageHistoryItem>>>((ref) {
  final filter = ref.watch(GarageHistoryProvider);
  final rescueHistoryAsync = ref.watch(garageRescueHistoryProvider);

  return rescueHistoryAsync.whenData((rescueList) {
    // Convert rescue requests to history items
    final historyItems = rescueList.map((rescue) {
      // Determine status based on rescue request status
      final status = rescue.status == 'completed' 
          ? GarageHistoryStatus.completed 
          : rescue.status == 'cancelled'
          ? GarageHistoryStatus.cancelled
          : GarageHistoryStatus.completed; // Default to completed for other statuses

      return GarageHistoryItem(
        rescueRequestId: rescue.id,
        vehicleType: rescue.vehicleType,
        vehicleName: rescue.vehicleType,
        vehicleModel: rescue.vehicleModel,
        image: kVehicleImages[rescue.vehicleType] ?? 'assets/images/illustrations/vehicle.png',
        status: status,
        issue: rescue.issues.join(', '),
        address: rescue.location,
        completedTime: rescue.completedAt?.toString() ?? rescue.createdAt.toString(),
        userName: rescue.userName,
        userPhone: rescue.userPhone,
        latitude: rescue.latitude,
        longitude: rescue.longitude,
      );
    }).toList();

    // Filter based on selection
    switch (filter) {
      case GarageHistoryFilter.completed:
        return historyItems.where((e) => e.status == GarageHistoryStatus.completed).toList();
      case GarageHistoryFilter.cancelled:
        return historyItems.where((e) => e.status == GarageHistoryStatus.cancelled).toList();
      default:
        return historyItems;
    }
  });
});
