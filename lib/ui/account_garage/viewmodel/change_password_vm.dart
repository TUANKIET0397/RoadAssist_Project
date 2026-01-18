import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/account_garage/models/change_password_state.dart';

final changePasswordProvider =
    StateNotifierProvider<ChangePasswordVM, ChangePasswordState>(
      (ref) => ChangePasswordVM(),
    );

class ChangePasswordVM extends StateNotifier<ChangePasswordState> {
  ChangePasswordVM() : super(ChangePasswordState());

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    /// ⛔ Chặn spam
    if (state.isLoading) return;

    /// Reset lỗi cũ
    state = state.copyWith(error: null, isSuccess: false);

    /// Validate
    if (newPassword.length < 6) {
      state = state.copyWith(error: 'Mật khẩu mới phải ≥ 6 ký tự');
      return;
    }

    if (newPassword != confirmPassword) {
      state = state.copyWith(error: 'Mật khẩu xác nhận không khớp');
      return;
    }

    try {
      state = state.copyWith(isLoading: true);

      /// TODO: Firebase Auth
      /// await authService.changePassword(oldPassword, newPassword);

      await Future.delayed(const Duration(seconds: 2)); // mock API

      /// Thành công
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Mật khẩu cũ không đúng');
    }
  }

  /// Optional: reset state khi rời màn hình
  void reset() {
    state = ChangePasswordState();
  }
}
