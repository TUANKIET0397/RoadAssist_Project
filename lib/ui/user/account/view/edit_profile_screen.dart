import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/user/account/viewmodel/account_vm.dart';
import 'package:road_assist/ui/user/account/viewmodel/edit_profile_vm.dart';
import 'package:road_assist/ui/user/account/widgets/birth_date_field.dart';
import 'package:road_assist/ui/user/account/widgets/profile_card.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _birthCtrl = TextEditingController();

  bool _inited = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _birthCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(accountStreamProvider);
    final isSaving = ref.watch(editProfileProvider);
    final _birthCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin cá nhân')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Không có dữ liệu'));
          }

          /// INIT FORM 1 LẦN
          if (!_inited) {
            _nameCtrl.text = user.name;
            _phoneCtrl.text = user.phone;
            _emailCtrl.text = user.email ?? '';
            _addressCtrl.text = user.address;
            if (!_inited) {
              _birthCtrl.text = user.birthDate ?? '';
              _inited = true;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                /// ===== PROFILE CARD =====
                ProfileCard(user: user),

                const SizedBox(height: 30),

                _field('Họ và tên *', _nameCtrl),
                _row2(
                  BirthDateField(controller: _birthCtrl),

                  _field('SĐT *', _phoneCtrl),
                ),
                _field('Email', _emailCtrl),
                _field('Địa chỉ', _addressCtrl),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            final error = await ref
                                .read(editProfileProvider.notifier)
                                .saveProfile(
                                  name: _nameCtrl.text,
                                  phone: _phoneCtrl.text,
                                  email: _emailCtrl.text,
                                  address: _addressCtrl.text,
                                  birthDate: _birthCtrl.text,
                                );

                            if (error != null && mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(error)));
                              return;
                            }

                            if (mounted) {
                              Navigator.pop(context);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: isSaving
                        ? const CircularProgressIndicator()
                        : const Text('Lưu thông tin'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _row2(Widget left, Widget right) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}
