import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'account_state.dart';
import '../model/vehicle_model.dart';
import '../model/account_action.dart';

final accountVmProvider = StateNotifierProvider<AccountViewModel, AccountState>(
  (ref) => AccountViewModel(ref),
);

class AccountViewModel extends StateNotifier<AccountState> {
  final Ref ref;

  AccountViewModel(this.ref) : super(AccountState.initial());

  /// ===== VEHICLE =====

  void changeName(Vehicle vehicle) {}

  void removeVehicle(Vehicle vehicle) {
    final updated = [...state.vehicles]..remove(vehicle);
    state = state.copyWith(vehicles: updated);
  }

  /// ===== LOGOUT =====
  void logout() {
    // TODO: clear session + navigate
  }

  /// ===== ACTION GRID =====
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

  void onActionTap(AccountActionType type) {
    // TODO: navigation
  }
}
