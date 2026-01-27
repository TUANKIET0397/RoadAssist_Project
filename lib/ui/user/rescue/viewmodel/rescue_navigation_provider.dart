import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/garage_model.dart';

/// Enum định nghĩa các màn hình trong rescue flow
enum RescueScreen {
  request,
  waiting,
  success,
  noGarage,
}

/// State class chứa toàn bộ thông tin navigation của rescue flow
class RescueNavigationState {
  final RescueScreen currentScreen;
  final String? rescueRequestId;
  final String? garageId;
  final String? garageName;
  final List<GarageModel> scannedGarages;

  const RescueNavigationState({
    this.currentScreen = RescueScreen.request,
    this.rescueRequestId,
    this.garageId,
    this.garageName,
    this.scannedGarages = const [],
  });

  RescueNavigationState copyWith({
    RescueScreen? currentScreen,
    String? rescueRequestId,
    String? garageId,
    String? garageName,
    List<GarageModel>? scannedGarages,
  }) {
    return RescueNavigationState(
      currentScreen: currentScreen ?? this.currentScreen,
      rescueRequestId: rescueRequestId ?? this.rescueRequestId,
      garageId: garageId ?? this.garageId,
      garageName: garageName ?? this.garageName,
      scannedGarages: scannedGarages ?? this.scannedGarages,
    );
  }

  /// Reset về trạng thái ban đầu
  RescueNavigationState reset() {
    return const RescueNavigationState();
  }
}

/// Notifier quản lý navigation state cho rescue flow
class RescueNavigationNotifier extends StateNotifier<RescueNavigationState> {
  RescueNavigationNotifier() : super(const RescueNavigationState());

  /// Chuyển sang màn hình waiting
  void navigateToWaiting(String requestId) {
    state = state.copyWith(
      currentScreen: RescueScreen.waiting,
      rescueRequestId: requestId,
    );
  }

  /// Chuyển sang màn hình success (garage đã nhận)
  void navigateToSuccess({
    required String requestId,
    String? garageId,
    String? garageName,
  }) {
    state = state.copyWith(
      currentScreen: RescueScreen.success,
      rescueRequestId: requestId,
      garageId: garageId,
      garageName: garageName,
    );
  }

  /// Chuyển sang màn hình no garage
  void navigateToNoGarage({
    required String requestId,
    List<GarageModel>? garages,
  }) {
    state = state.copyWith(
      currentScreen: RescueScreen.noGarage,
      rescueRequestId: requestId,
      scannedGarages: garages ?? [],
    );
  }

  /// Quay lại màn hình request (reset state)
  void backToRequest() {
    state = state.reset();
  }

  /// Cập nhật danh sách garage đã quét
  void updateScannedGarages(List<GarageModel> garages) {
    state = state.copyWith(scannedGarages: garages);
  }

  /// Thêm garage vào danh sách (tránh duplicate)
  void addScannedGarage(GarageModel garage) {
    if (!state.scannedGarages.any((g) => g.id == garage.id)) {
      state = state.copyWith(
        scannedGarages: [...state.scannedGarages, garage],
      );
    }
  }

  /// Thêm nhiều garage vào danh sách (tránh duplicate)
  void addScannedGarages(List<GarageModel> garages) {
    final existingIds = state.scannedGarages.map((g) => g.id).toSet();
    final newGarages = garages.where((g) => !existingIds.contains(g.id)).toList();
    
    if (newGarages.isNotEmpty) {
      state = state.copyWith(
        scannedGarages: [...state.scannedGarages, ...newGarages],
      );
    }
  }
}

/// Provider cho rescue navigation
final rescueNavigationProvider =
    StateNotifierProvider.autoDispose<RescueNavigationNotifier, RescueNavigationState>(
  (ref) => RescueNavigationNotifier(),
);
