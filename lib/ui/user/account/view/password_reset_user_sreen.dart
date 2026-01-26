import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/theme/app_palette.dart';
import 'package:road_assist/ui/garage/account/models/change_password_state.dart';
import 'package:road_assist/ui/garage/account/viewmodel/change_password_vm.dart';
import 'package:road_assist/ui/garage/account/widgets/password_field.dart';
import 'package:road_assist/ui/user/account/viewmodel/account_vm.dart';
import 'package:road_assist/ui/user/account/widgets/profile_card.dart';

class PasswordResetUserSreen extends ConsumerStatefulWidget {
  const PasswordResetUserSreen({super.key});

  @override
  ConsumerState<PasswordResetUserSreen> createState() =>
      _PasswordResetUserSreenState();
}

class _PasswordResetUserSreenState
    extends ConsumerState<PasswordResetUserSreen> {
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  /// 👉 Điều khiển scroll
  final _scrollController = ScrollController();

  /// 👉 Focus để bắt sự kiện bàn phím mở
  final _oldFocus = FocusNode();
  final _newFocus = FocusNode();
  final _confirmFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    /// Hàm scroll xuống cuối (để lộ nút)
    void scrollToBottom() {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (_scrollController.hasClients) {
          final max = _scrollController.position.maxScrollExtent;
          final offset = max - 280; // 👈 chỉnh con số này

          _scrollController.animateTo(
            offset.clamp(0, max),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    /// Khi focus bất kỳ ô nào → scroll
    _oldFocus.addListener(() {
      if (_oldFocus.hasFocus) scrollToBottom();
    });
    _newFocus.addListener(() {
      if (_newFocus.hasFocus) scrollToBottom();
    });
    _confirmFocus.addListener(() {
      if (_confirmFocus.hasFocus) scrollToBottom();
    });
  }

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();

    _oldFocus.dispose();
    _newFocus.dispose();
    _confirmFocus.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(accountStreamProvider);
    final pwdState = ref.watch(changePasswordProvider);

    /// ✅ LISTEN SIDE-EFFECT (SnackBar + Navigator)
    ref.listen<ChangePasswordState>(changePasswordProvider, (prev, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đổi mật khẩu thành công')),
        );
        Navigator.pop(context);
      }

      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    return
    /// USER INFO
    userAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: CircularProgressIndicator(),
      ),
      error: (e, _) => Text('Lỗi: $e'),
      data: (user) {
        if (user == null) {
          return const Text('Không có dữ liệu người dùng');
        }
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Color.fromRGBO(37, 44, 59, 1),
            elevation: 0,
            title: const Text(
              'Đổi mật khẩu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3b82f6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          body: Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: const
            BoxDecoration(
              gradient: LinearGradient(
                colors: AppPalette.bgColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// GARAGE INFO
                  // GarageCard(garage: garage),
                  ProfileCard(user: user),
                  const SizedBox(height: 38),

                  /// PASSWORD INPUTS
                  PasswordField(
                    label: 'Mật khẩu cũ',
                    controller: _oldController,
                    focusNode: _oldFocus,
                  ),
                  PasswordField(
                    label: 'Mật khẩu mới',
                    controller: _newController,
                    focusNode: _newFocus,
                  ),
                  PasswordField(
                    label: 'Xác nhận mật khẩu',
                    controller: _confirmController,
                    focusNode: _confirmFocus,
                  ),

                  const SizedBox(height: 32),

                  /// CHANGE PASSWORD BUTTON (VẪN TRONG BODY)
                  SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: pwdState.isLoading
                          ? null
                          : () {
                              ref
                                  .read(changePasswordProvider.notifier)
                                  .changePassword(
                                    oldPassword: _oldController.text,
                                    newPassword: _newController.text,
                                    confirmPassword: _confirmController.text,
                                  );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(75, 76, 237, 1),
                        shadowColor: const Color.fromRGBO(55, 182, 233, 1),
                        elevation: 8,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: pwdState.isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Đổi mật khẩu',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// FOOTER
                  const Text(
                    'Đổi mật khẩu để nâng cao bảo mật!',
                    style: TextStyle(color: Colors.white),
                  ),
                  // const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
