import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/garage_model.dart';
import 'package:road_assist/ui/auth/view/user_register_screen.dart';
import 'package:road_assist/ui/auth/widget/password_text_field.dart';
import 'package:road_assist/ui/auth_garage/viewmodel/garage_register_vm.dart';
import 'package:road_assist/ui/auth_garage/widget/custom_text_field.dart';
import 'package:road_assist/ui/auth_garage/widget/day_selector.dart';
import 'package:road_assist/ui/auth_garage/widget/time_picker_field.dart';
import 'package:road_assist/ui/auth_garage/widget/service_chip.dart';
import 'package:road_assist/ui/auth_garage/widget/vehicle_type_item.dart';
import 'package:road_assist/ui/auth_garage/widget/section_header.dart';
import 'package:road_assist/ui/map/location_pick_result.dart';
import 'package:road_assist/ui/map/map_pick_screen.dart';
import 'package:road_assist/ui/auth_garage/view/garage_success_view.dart';

class GarageRegisterView extends ConsumerWidget {
  const GarageRegisterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(garageRegisterVMProvider);
    final vmNotifier = ref.read(garageRegisterVMProvider.notifier);

    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF202A44),
              Color(0xFF334268),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo and Title
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/images/logos/logo.png', height: 160),
                      const Text(
                        'Đăng kí Garage',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00BFFC),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Vui lòng điền thông tin bên dưới',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Garage Info Section
                const SectionHeader(title: 'Thông tin Garage'),
                CustomTextField(
                  controller: vm.nameController,
                  hint: 'Tên garage',
                ),
                CustomTextField(
                  controller: vm.taxCodeController,
                  hint: 'Mã số thuế',
                ),
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapPickScreen(
                          initialLat: vm.latitude,
                          initialLng: vm.longitude,
                        ),
                      ),
                    );

                    if (result != null && result is Map<String, dynamic>) {
                      // Cập nhật lat, lng qua ViewModel
                      await vmNotifier.setLocationFromLatLng(
                        lat: result['lat'],
                        lng: result['lng'],
                      );

                      // Cập nhật address trực tiếp vào controller
                      if (result['address'] != null) {
                        vm.addressController.text = result['address'];
                      }
                    }
                  },
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: vm.addressController,
                      hint: 'Chọn vị trí Garage trên bản đồ',
                      suffixIcon: const Icon(
                        Icons.location_on,
                        color: Color(0xFF4FC3F7),
                      ),
                    ),
                  ),
                ),

                CustomTextField(
                  controller: vm.phoneController,
                  hint: 'Số điện thoại Garage',
                ),

                // Password Section
                PasswordTextField(
                  controller: vm.passwordController,
                  hint: 'Mật khẩu',
                  textColor: Color(0xFF69BFF9),
                ),
                PasswordTextField(
                  controller: vm.confirmPasswordController,
                  hint: 'Xác nhận mật khẩu',
                  textColor: Color(0xFF69BFF9),
                ),

                // Operating Days Section
                const SectionHeader(title: 'Ngày hoạt động'),
                DaySelector(
                  selectedDays: vm.selectedDays,
                  onDayTap: vm.toggleDay,
                ),

                // Operating Hours Section
                const SectionHeader(title: 'Giờ hoạt động'),
                Consumer(
                  builder: (context, ref, _) {
                    final vm = ref.watch(garageRegisterVMProvider);

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF243158),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFF34CAE8),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TimePickerField(
                            time: vm.openTime,
                            onTimeSelected: (time) {
                              ref
                                  .read(garageRegisterVMProvider)
                                  .setOpenTime(time);
                            },
                          ),
                          const Text(
                            '  —  ',
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                          TimePickerField(
                            time: vm.closeTime,
                            onTimeSelected: (time) {
                              ref
                                  .read(garageRegisterVMProvider)
                                  .setCloseTime(time);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Services Section
                const SectionHeader(title: 'Dịch vụ hỗ trợ'),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: vm.allServices.map((s) {
                    return ServiceChip(
                      label: s,
                      isSelected: vm.selectedServices.contains(s),
                      onTap: () => vm.toggleService(s),
                    );
                  }).toList(),
                ),

                // Vehicle Types Section
                const SectionHeader(title: 'Loại Phương Tiện Hỗ trợ'),
                Column(
                  children: [
                    ...vm.selectedVehicleTypes.asMap().entries.map((entry) {
                      return VehicleTypeItem(
                        selectedType: entry.value,
                        allTypes: vm.allVehicleTypes,
                        onChanged: (newValue) {
                          if (newValue != null) {
                            vmNotifier.updateVehicleType(entry.key, newValue);
                          }
                        },
                        onAdd: () {},
                        onRemove: () => vmNotifier.removeVehicleType(entry.key),
                      );
                    }).toList(),
                    if (vm.selectedVehicleTypes.length < vm.allVehicleTypes.length)
                      VehicleTypeItem(
                        allTypes: vm.allVehicleTypes,
                        isAddButton: true,
                        onAdd: vmNotifier.addVehicleType,
                      ),
                  ],
                ),
                const SizedBox(height: 24),


                const SizedBox(height: 24),

                // Terms and Conditions
                Row(
                  children: [
                    Checkbox(
                      value: vm.isAgree,
                      onChanged: (val) {
                        if (val != null) {
                          vmNotifier.toggleAgree(val);
                        }
                      },
                      checkColor: Colors.lightBlue,
                      activeColor: Color(0xFF000718),
                    ),
                    const Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'Tôi đồng ý với ',
                          style: TextStyle(color: Color(0xFF2299E1)),
                          children: [
                            TextSpan(
                              text: 'Điều khoản sử dụng',
                              style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                            ),
                            TextSpan(text: ' và '),
                            TextSpan(
                              text: 'chính sách người dùng',
                              style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                if (vm.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      vm.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                const SizedBox(height: 16),
                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: vm.isLoading
                        ? null
                        : () async {
                      final ok = await ref
                          .read(garageRegisterVMProvider)
                          .registerGarage();

                      if (ok && context.mounted) {
                        _showSuccessDialog(context, vm);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: vm.isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Đăng ký tài khoản',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Trở về tài khoản ? ',
                        style: TextStyle(
                          color: Color(0xFF53789A),
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserRegisterView(),
                            ),
                          );
                        },
                        child: const Text(
                          'Người dùng',
                          style: TextStyle(
                            color: Color(0xFF00D4FF),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _showSuccessDialog(
      BuildContext context,
      GarageRegisterViewModel vm,
      ) {
    final garageModel = GarageModel(
      id: '',
      name: vm.nameController.text,
      address: vm.addressController.text,
      phone: vm.phoneController.text,
      distance: null,
      vehicleTypes: vm.selectedVehicleTypes,
      issues: vm.selectedServices.toList(),
      openTime:
      '${vm.openTime.hour.toString().padLeft(2, '0')}:${vm.openTime.minute.toString().padLeft(2, '0')}',
      closeTime:
      '${vm.closeTime.hour.toString().padLeft(2, '0')}:${vm.closeTime.minute.toString().padLeft(2, '0')}',
      lat: vm.latitude,
      lng: vm.longitude,
      isActive: false,
      rating: 0.0,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GarageSuccessView(garage: garageModel),
      ),
    );
  }

}
