import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/theme/app_palette.dart';
import 'package:road_assist/ui/auth/viewmodel/garage_register_vm.dart';
import 'package:road_assist/ui/map/location_pick_result.dart';
import 'package:road_assist/ui/map/map_pick_screen.dart';
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
  File? _avatarFile;

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
    final vm = ref.watch(garageRegisterVMProvider);
    final vmNotifier = ref.read(garageRegisterVMProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(37, 44, 59, 1),
        elevation: 0,
        title: const Text(
          'Thông tin cá nhân',
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
        decoration: const
        BoxDecoration(
          gradient: LinearGradient(
            colors: AppPalette.bgColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: userAsync.when(
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
                  ProfileCard(
                    user: user,
                    onAvatarPicked: (file) {
                      setState(() {
                        _avatarFile = file;
                      });
                    },
                  ),


                  const SizedBox(height: 30),

                  _field('Họ và tên *', _nameCtrl),
                  _row2(
                    BirthDateField(controller: _birthCtrl),

                    _field('SĐT *', _phoneCtrl),
                  ),
                  _field('Email', _emailCtrl),

                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push<LocationPickResult>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapPickScreen(
                          initialLat: vm.latitude,
                          initialLng: vm.longitude,
                        ),
                      ),
                    );

                    if (result != null) {
                      await vmNotifier.setLocationFromLatLng(
                        lat: result.latitude,
                        lng: result.longitude,
                        address: result.address,
                      );
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Đia chỉ *",
                      labelStyle: const TextStyle(color: Colors.white70),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF4B4CED),
                          width: 2,
                        ),
                      ),
                      suffixIcon: const Icon(
                        Icons.location_on,
                        color: Colors.white70,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        vm.addressController.text.isEmpty
                            ? 'Chọn vị trí'
                            : vm.addressController.text,
                        style: TextStyle(
                          color: vm.addressController.text.isEmpty
                              ? Colors.white70
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                  Center(
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
                          address: vm.addressController.text,
                          birthDate: _birthCtrl.text,
                          avatarFile: _avatarFile,
                        );

                        if (error != null && mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(error)));
                          return;
                        }

                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4B4CED),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text(
                        'Lưu thông tin',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.white,
              width: 1,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF4B4CED),
              width: 2,
            ),
          ),
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
