import 'package:road_assist/data/models/garage_model.dart';

class GarageState {
  final GarageModel savedGarage; // Garage đã lưu, hiển thị trên card
  final GarageModel draftGarage; // Garage đang chỉnh sửa trong form
  final List<int> workingDays; // Ngày làm việc (không có trong GarageModel)
  final String? taxCode; // Mã số thuế (không có trong GarageModel)
  final bool isLoading;

  const GarageState({
    required this.savedGarage,
    required this.draftGarage,
    this.workingDays = const [1, 2, 3, 4, 5],
    this.taxCode,
    this.isLoading = false,
  });

  GarageState copyWith({
    GarageModel? savedGarage,
    GarageModel? draftGarage,
    List<int>? workingDays,
    String? taxCode,
    bool? isLoading,
  }) {
    return GarageState(
      savedGarage: savedGarage ?? this.savedGarage,
      draftGarage: draftGarage ?? this.draftGarage,
      workingDays: workingDays ?? this.workingDays,
      taxCode: taxCode ?? this.taxCode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
