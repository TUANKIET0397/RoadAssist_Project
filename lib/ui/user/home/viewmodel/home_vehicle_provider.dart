import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/providers/auth_provider.dart';
import 'package:road_assist/data/datasources/local/vehicle_constants.dart';
import 'package:road_assist/ui/user/home/models/vehicle_grid_data.dart';

/// Provider lấy danh sách xe đã đăng ký từ account
final myVehiclesProvider = Provider<AsyncValue<List<VehicleGridData>>>((ref) {
  final vehiclesAsync = ref.watch(allUserVehiclesProvider);
  
  return vehiclesAsync.when(
    data: (vehicles) {
      final myVehicles = vehicles.map((vehicle) {
        final image = kVehicleImages[vehicle.type] ?? 'assets/images/illustrations/vehicle.png';
        return VehicleGridData(
          title: vehicle.type,
          subtitle1: vehicle.description ?? vehicle.type,
          subtitle2: 'Đã đăng ký',
          image: image,
          isFavorite: true,
          vehicleType: vehicle.type, // Thêm vehicleType để dùng khi navigate
        );
      }).toList();
      return AsyncValue.data(myVehicles);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider lấy danh sách xe CHƯA đăng ký (xe khác)
final otherVehiclesProvider = Provider<AsyncValue<List<VehicleGridData>>>((ref) {
  final vehiclesAsync = ref.watch(allUserVehiclesProvider);
  
  return vehiclesAsync.when(
    data: (vehicles) {
      // Lấy danh sách type xe đã đăng ký
      final registeredTypes = vehicles.map((v) => v.type).toSet();
      
      // Lọc ra các xe chưa đăng ký từ kUserVehicleTypes
      final otherVehicles = kUserVehicleTypes
          .where((type) => !registeredTypes.contains(type))
          .map((type) {
        final image = kVehicleImages[type] ?? 'assets/images/illustrations/vehicle.png';
        return VehicleGridData(
          title: type,
          subtitle1: type,
          subtitle2: 'Chưa đăng ký',
          image: image,
          isFavorite: false,
          vehicleType: type,
        );
      }).toList();
      
      return AsyncValue.data(otherVehicles);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider để lưu xe được chọn trước khi vào trang rescue
final preSelectedVehicleTypeProvider = StateProvider<String?>((ref) => null);

/// Provider để lưu issue được chọn trước khi vào trang rescue
final preSelectedIssueProvider = StateProvider<String?>((ref) => null);
