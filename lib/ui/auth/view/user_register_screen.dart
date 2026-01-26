import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:road_assist/ui/auth/view/login_screen.dart';
import 'package:road_assist/ui/auth/viewmodel/user_register_vm.dart';
import 'package:road_assist/ui/auth/widgets/custom_text_field.dart';
import 'package:road_assist/ui/auth/widgets/vehicle_type_item.dart';
import 'package:road_assist/ui/auth/widgets/password_text_field.dart';

class UserRegisterScreen extends ConsumerWidget {
  const UserRegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(userRegisterVMProvider);
    final vmNotifier = ref.read(userRegisterVMProvider.notifier);

    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF202A44), Color(0xFF334268)],
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
                      Image.asset('assets/images/logos/logo.png', height: 140),
                      const SizedBox(height: 12),
                      const Text(
                        'Đăng ký tài khoản',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00BFFC),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Vui lòng điền thông tin bên dưới',
                        style: TextStyle(fontSize: 14, color: Colors.white38),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Thông tin cá nhân Section
                _buildSectionHeader('Thông tin cá nhân'),
                CustomTextField(
                  controller: vm.nameController,
                  hint: 'Họ và tên',
                  hintColor: Colors.white70,
                ),
                CustomTextField(
                  controller: vm.phoneController,
                  hint: 'Số điện thoại của bạn',
                  hintColor: Colors.white70
                ),

                // Password Section
                PasswordTextField(
                  controller: vm.passwordController,
                  hint: 'Mật khẩu',
                ),
                PasswordTextField(
                  controller: vm.confirmPasswordController,
                  hint: 'Xác nhận mật khẩu',
                ),

                // Vehicle Type Section
                _buildSectionHeader('Thông tin phương tiện'),
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
                    if (vm.selectedVehicleTypes.length <
                        vm.allVehicleTypes.length)
                      VehicleTypeItem(
                        allTypes: vm.allVehicleTypes,
                        isAddButton: true,
                        onAdd: vmNotifier.addVehicleType,
                      ),
                  ],
                ),

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
                      activeColor: const Color(0xFF000718),
                    ),
                    const Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'Tôi đồng ý với ',
                          style: TextStyle(color: Color(0xFF2299E1)),
                          children: [
                            TextSpan(
                              text: 'Điều khoản sử dụng',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            TextSpan(text: ' và '),
                            TextSpan(
                              text: 'chính sách người dùng',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Error Message
                if (vm.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      vm.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: vm.isLoading
                        ? null
                        : () async {
                            final success = await vmNotifier.registerUser();
                            if (success && context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đăng ký thành công!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A3E0),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: vm.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Đăng ký tài khoản',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Already have account
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.go('/auth/garage/register');
                        },
                        child: const Text(
                          'Đăng ký Garage',
                          style: TextStyle(
                            color: Color(0xFF00D4FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Text(
                        '  |  ',
                        style: TextStyle(
                          color: Color(0xFF53789A),
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.go('/auth/user/login');

                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => const LoginScreen(),
                          //   ),
                          // );
                        },
                        child: const Text(
                          'Đăng nhập',
                          style: TextStyle(
                            color: Color(0xFF00D4FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF00D4FF),
        ),
      ),
    );
  }
}
