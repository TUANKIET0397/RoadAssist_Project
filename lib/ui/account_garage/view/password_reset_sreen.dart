import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/account_garage/models/change_password_state.dart';
import 'package:road_assist/ui/account_garage/viewmodel/change_password_vm.dart';
import 'package:road_assist/ui/account_garage/viewmodel/garage_provider.dart';
import 'package:road_assist/ui/account_garage/widgets/garage_card.dart';
import 'package:road_assist/ui/account_garage/widgets/password_field.dart';

class PasswordResetSreen extends ConsumerStatefulWidget {
  const PasswordResetSreen({super.key});

  @override
  ConsumerState<PasswordResetSreen> createState() => _PasswordResetSreenState();
}

class _PasswordResetSreenState extends ConsumerState<PasswordResetSreen> {
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
    final colorScheme = Theme.of(context).colorScheme;
    final garage = ref.watch(garageProvider);
    final state = ref.watch(changePasswordProvider);

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

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Mật khẩu'),
        backgroundColor: colorScheme.surface,
        actions: [
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(right: 16, bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [
                  Color.fromRGBO(79, 172, 254, 1),
                  Color.fromRGBO(0, 242, 254, 1),
                ],
              ),
            ),
            child: const Icon(Icons.key_sharp, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
            GarageCard(garage: garage),

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
                onPressed: state.isLoading
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
                child: state.isLoading
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
    );
  }
}
