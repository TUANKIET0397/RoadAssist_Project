import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';
import 'package:road_assist/ui/navigation/viewmodel/rescue_navigation_provider.dart';

/// State for the success screen
class RescueSuccessState {
  final bool isLoading;
  final RescueRequestModel? rescueRequest;

  RescueSuccessState({this.isLoading = false, this.rescueRequest});

  RescueSuccessState copyWith({bool? isLoading, RescueRequestModel? rescueRequest}) {
    return RescueSuccessState(
      isLoading: isLoading ?? this.isLoading,
      rescueRequest: rescueRequest ?? this.rescueRequest,
    );
  }
}

/// Notifier
class RescueSuccessNotifier extends StateNotifier<RescueSuccessState> {
  final Ref ref;
  RescueSuccessNotifier(this.ref) : super(RescueSuccessState());

  /// Load rescue data. If a request is provided it will be used, otherwise
  /// we try to read the currently selected rescue from `selectedRescueProvider`.
  Future<void> loadRescueData({RescueRequestModel? request}) async {
    state = state.copyWith(isLoading: true);

    await Future.delayed(const Duration(milliseconds: 500)); // simulate loading

    if (request != null) {
      state = state.copyWith(isLoading: false, rescueRequest: request);
      return;
    }

    final selected = ref.read(selectedRescueProvider);
    if (selected != null) {
      state = state.copyWith(isLoading: false, rescueRequest: selected);
      return;
    }

    // fallback mock data
    final mock = RescueRequestModel(
      id: 'mock-1',
      userId: 'user-1',
      userName: 'Nguyen Gia Bao',
      userPhone: '0337760280',
      vehicleType: 'Xe tay ga',
      vehicleModel: 'Honda SH Mode 2025',
      issues: ['Bể lốp', 'Hư máy', 'Vận chuyển xe'],
      location: '15B Nguyễn Lương Bằng, P25, TP HCM',
      latitude: 10.762622,
      longitude: 106.660172,
      imageUrl: null,
      status: 'pending',
      statusUpdates: [
        'Garage đã nhận yêu cầu',
        'Garage đang điều phối kỹ thuật',
        'Garage sẽ liên hệ trong ít phút',
      ],
      createdAt: DateTime.now(),
    );

    state = state.copyWith(isLoading: false, rescueRequest: mock);
  }

  void trackRescueStatus() {
    // implement navigation or logic to open tracking screen
    // for now just print
    print('Tracking rescue status...');
  }

  void chatWithGarage() {
    // implement navigation to chat
    print('Opening chat with garage...');
  }
}

final rescueSuccessProvider = StateNotifierProvider<RescueSuccessNotifier, RescueSuccessState>(
  (ref) => RescueSuccessNotifier(ref),
);