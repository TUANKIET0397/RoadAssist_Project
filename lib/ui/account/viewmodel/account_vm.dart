import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/account/model/account_action.dart';
import 'package:road_assist/ui/account/model/vehicle_model.dart';
import 'package:road_assist/ui/account/viewmodel/account_state.dart';

final accountVmProvider = StateNotifierProvider<AccountViewModel, AccountState>(
  (ref) => AccountViewModel(ref),
);

class AccountViewModel extends StateNotifier<AccountState> {
  AccountViewModel(this.ref) : super(AccountState.initial());
  final Ref ref;

  void updateVehicleDescription(Vehicle vehicle, String? description) {
    final updated = state.vehicles.map((v) {
      if (v == vehicle) {
        return Vehicle(
          name: v.name,
          image: v.image,
          description: description?.trim().isEmpty ?? true ? null : description,
        );
      }
      return v;
    }).toList();

    state = state.copyWith(vehicles: updated);
  }

  void removeVehicle(Vehicle vehicle) {
    final updated = [...state.vehicles]..remove(vehicle);
    state = state.copyWith(vehicles: updated);
  }

  List<AccountActionItem> get actions => const [
    AccountActionItem(
      type: AccountActionType.rescues,
      title: 'Các cuộc cứu hộ',
      icon: Icons.search,
    ),
    AccountActionItem(
      type: AccountActionType.favoriteGarage,
      title: 'Garage yêu thích',
      icon: Icons.favorite_border,
    ),
    AccountActionItem(
      type: AccountActionType.personalInfo,
      title: 'Thông tin cá nhân',
      icon: Icons.person_outline,
    ),
    AccountActionItem(
      type: AccountActionType.changePassword,
      title: 'Đổi mật khẩu',
      icon: Icons.lock_outline,
    ),
  ];

  void logout() {
    // TODO
  }

  void onActionTap(AccountActionType type) {
    // TODO
  }
}
