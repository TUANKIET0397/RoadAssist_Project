import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/change_password_state.dart';

final changePasswordProvider =
    StateNotifierProvider<ChangePasswordVM, ChangePasswordState>(
      (ref) => ChangePasswordVM(),
    );

class ChangePasswordVM extends StateNotifier<ChangePasswordState> {
  ChangePasswordVM() : super(const ChangePasswordState());

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // 1️⃣ Validate local
    if (newPassword != confirmPassword) {
      state = state.copyWith(error: 'Mật khẩu xác nhận không khớp');
      return;
    }

    if (newPassword.length < 6) {
      state = state.copyWith(error: 'Mật khẩu phải có ít nhất 6 ký tự');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'Người dùng chưa đăng nhập',
        );
      }

      final email = user.email;
      if (email == null) {
        throw FirebaseAuthException(
          code: 'no-email',
          message: 'Không tìm thấy email người dùng',
        );
      }

      // 2️⃣ Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: email,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // 3️⃣ Update password
      await user.updatePassword(newPassword);

      state = state.copyWith(isLoading: false, isSuccess: true);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _mapError(e));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Đổi mật khẩu thất bại');
    }
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
        return 'Mật khẩu cũ không đúng';
      case 'weak-password':
        return 'Mật khẩu mới quá yếu';
      case 'requires-recent-login':
        return 'Vui lòng đăng nhập lại để đổi mật khẩu';
      default:
        return e.message ?? 'Có lỗi xảy ra';
    }
  }
}
