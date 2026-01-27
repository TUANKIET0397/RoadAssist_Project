import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:road_assist/core/providers/auth_provider.dart';
import 'package:road_assist/core/theme/app_palette.dart';
import 'package:road_assist/ui/garage/account/models/change_password_state.dart';
import 'package:road_assist/ui/garage/account/viewmodel/change_password_vm.dart';
import 'package:road_assist/ui/garage/account/viewmodel/garage_vm.dart';
import 'package:road_assist/ui/garage/account/widgets/garage_card.dart';
import 'package:road_assist/ui/garage/account/widgets/password_field.dart';

class PasswordResetSreen extends ConsumerStatefulWidget {
  const PasswordResetSreen({super.key});

  @override
  ConsumerState<PasswordResetSreen> createState() => _PasswordResetSreenState();
}

class _PasswordResetSreenState extends ConsumerState<PasswordResetSreen> {
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  final _scrollController = ScrollController();

  final _oldFocus = FocusNode();
  final _newFocus = FocusNode();
  final _confirmFocus = FocusNode();

  late final ProviderSubscription<ChangePasswordState> _passwordListener;

  @override
  void initState() {
    super.initState();

    /// 👉 Scroll khi mở bàn phím
    void scrollToBottom() {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (!_scrollController.hasClients) return;
        final max = _scrollController.position.maxScrollExtent;
        _scrollController.animateTo(
          (max - 250).clamp(0, max),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }

    _oldFocus.addListener(() {
      if (_oldFocus.hasFocus) scrollToBottom();
    });
    _newFocus.addListener(() {
      if (_newFocus.hasFocus) scrollToBottom();
    });
    _confirmFocus.addListener(() {
      if (_confirmFocus.hasFocus) scrollToBottom();
    });

    /// ✅ LISTEN SIDE EFFECT (CHỈ 1 LẦN)
    _passwordListener = ref.listenManual<ChangePasswordState>(
      changePasswordProvider,
      (prev, next) {
        if (!mounted) return;

        if (next.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đổi mật khẩu thành công'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop("/garage/account");
        }

        if (next.error != null && next.error != prev?.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _passwordListener.close();

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
    final userId = ref.watch(userIdProvider);
    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Chưa đăng nhập')));
    }
    final colorScheme = Theme.of(context).colorScheme;
    final garageState = ref.watch(garageProvider(userId));
    final garage = garageState.savedGarage;

    final pwdState = ref.watch(changePasswordProvider);

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
      body: Container(
        decoration: const BoxDecoration(
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
            bottom: MediaQuery.of(context).viewInsets.bottom + 10,
          ),
          child: Column(
            children: [
              GarageCard(garage: garage),
              const SizedBox(height: 36),

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

              SizedBox(
                width: 300,
                child: ElevatedButton(
                  onPressed: pwdState.isLoading
                      ? null
                      : _onChangePasswordPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(75, 76, 237, 1),
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
              const Text(
                'Đổi mật khẩu để nâng cao bảo mật!',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  void _onChangePasswordPressed() {
    final oldPwd = _oldController.text.trim();
    final newPwd = _newController.text.trim();
    final confirmPwd = _confirmController.text.trim();

    if (oldPwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
      _showSnack('Vui lòng nhập đầy đủ thông tin');
      return;
    }

    if (newPwd.length < 6) {
      _showSnack('Mật khẩu mới phải ≥ 6 ký tự');
      return;
    }

    if (newPwd != confirmPwd) {
      _showSnack('Mật khẩu xác nhận không khớp');
      return;
    }

    ref
        .read(changePasswordProvider.notifier)
        .changePassword(
          oldPassword: oldPwd,
          newPassword: newPwd,
          confirmPassword: confirmPwd,
        );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.orange),
    );
  }
}
