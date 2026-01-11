import 'package:road_assist/data/models/response/user_model.dart';
import '../model/vehicle_model.dart';

class AccountState {
  final UserModel user;
  final List<Vehicle> vehicles;

  const AccountState({required this.user, required this.vehicles});

  factory AccountState.initial() {
    return AccountState(user: UserModel.mock(), vehicles: Vehicle.mockList());
  }

  AccountState copyWith({UserModel? user, List<Vehicle>? vehicles}) {
    return AccountState(
      user: user ?? this.user,
      vehicles: vehicles ?? this.vehicles,
    );
  }
}
