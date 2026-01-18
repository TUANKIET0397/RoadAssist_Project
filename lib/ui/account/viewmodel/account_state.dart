import 'package:road_assist/data/models/user_model.dart';
import 'package:road_assist/ui/account/model/vehicle_model.dart';

class AccountState {
  final UserModel user;
  final List<Vehicle> vehicles;

  /// EDIT STATE
  final Vehicle? editingVehicle;
  final String editingDescription;

  const AccountState({
    required this.user,
    required this.vehicles,
    this.editingVehicle,
    this.editingDescription = '',
  });

  factory AccountState.initial() {
    return AccountState(
      user: UserModel.mock(),
      vehicles: Vehicle.mockList(),
      editingVehicle: null,
      editingDescription: '',
    );
  }

  AccountState copyWith({
    UserModel? user,
    List<Vehicle>? vehicles,
    Vehicle? editingVehicle,
    bool clearEditingVehicle = false,
    String? editingDescription,
  }) {
    return AccountState(
      user: user ?? this.user,
      vehicles: vehicles ?? this.vehicles,
      editingVehicle: clearEditingVehicle
          ? null
          : editingVehicle ?? this.editingVehicle,
      editingDescription: editingDescription ?? this.editingDescription,
    );
  }
}
