import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:road_assist/core/auth/auth_state.dart';
import 'package:road_assist/core/providers/selected_role.dart';
import 'package:road_assist/core/routes/route_paths.dart';
import 'package:road_assist/core/services/call_hotline.dart';
import 'package:road_assist/ui/auth/viewmodel/login_viewmodel.dart';

class AuthRoleScreen extends ConsumerWidget {
  const AuthRoleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final h = MediaQuery.of(context).size.height;
    final viewModel = ref.watch(loginViewModelProvider);
    final hotlineService = HotlineService();

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: h * 0.5,
            child: Image.asset(
              'assets/images/illustrations/background_car_login.jpg',
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: h * 0.5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1a2840).withOpacity(0.5),
                    const Color(0xFF1a2840).withOpacity(0.95),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: h * 0.45,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1a2840),
                    Color(0xFF2d3f56),
                    Color(0xFF1a2840),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.2,
                colors: [
                  const Color(0xFF34C8E8).withOpacity(0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo
                Image.asset(
                  'assets/images/logos/logo.png',
                  width: 180,
                  height: 180,
                ),

                const Spacer(flex: 2),

                // Role selection buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _RoleButton(
                      icon: Image.asset(
                        'assets/images/icons/garagelogin.png',
                      ),
                      label: 'Tài khoản\nGarage',
                      isSelected: false,
                      onTap: () {
                        ref.read(selectedRoleProvider.notifier).state =
                            UserRole.garage;
                        context.go(RoutePaths.garageLogin);
                      },
                    ),
                    const SizedBox(width: 24),
                    _RoleButton(
                      icon: Image.asset(
                        'assets/images/icons/userlogin.png',
                      ),
                      label: 'Tài khoản\nNgười dùng',
                      isSelected: true,
                      onTap: () {
                        ref.read(selectedRoleProvider.notifier).state =
                            UserRole.customer;
                        context.go(RoutePaths.userLogin);
                      },
                    ),
                  ],
                ),

                const Spacer(flex: 2),

                // Emergency support card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFF4B4CED),
                        Color(0xFF34CAE8),
                      ],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  padding: const EdgeInsets.all(1),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF19253B),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.warning,
                              color: Colors.orange,
                              size: 20,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Hỗ trợ khẩn cấp',
                              style: TextStyle(
                                color: Color(0xFFF88000),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Trong trường hợp khẩn cấp bạn có thể gọi trực tiếp bằng số Hotline bên dưới để hỗ trợ ngay.',
                          style: TextStyle(
                            color: Color(0xFF7181A6),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Xác nhận'),
                                  content: const Text(
                                    'Bạn sắp gọi hotline hỗ trợ khẩn cấp. Tiếp tục?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('HỦY'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('GỌI'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                try {
                                  await hotlineService.callHotline();
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Không thể gọi hotline'),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(249, 64, 90, 0.39),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.phone, size: 20),
                                SizedBox(width: 4),
                                Text(
                                  'Gọi Ngay',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Social login
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialButton(
                        iconPath: 'assets/images/logos/gmail_logo.png',
                        onTap: () async {
                          final user = await viewModel.loginWithGoogle();
                          if (user != null && context.mounted) {
                            context.go('/home');
                          }
                        },
                      ),
                      const SizedBox(width: 16),
                      _SocialButton(
                        iconPath: 'assets/images/logos/apple_logo.png',
                        onTap: () {},
                      ),
                      const SizedBox(width: 16),
                      _SocialButton(
                        iconPath: 'assets/images/logos/facebook_logo.png',
                        onTap: () {
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Sign up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Chưa có tài khoản? ',
                      style: TextStyle(
                        color: Color(0xFF53789A),
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/auth/user/register');
                      },
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Đăng ký ngay',
                        style: TextStyle(
                          color: Color(0xFF00D4FF),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFF2a3d50),
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 60, height: 60, child: icon),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? const Color(0xFF0DD7FF) : Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends ConsumerWidget {
  final String iconPath;
  final VoidCallback onTap;

  const _SocialButton({
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        iconPath,
        width: 56,
        height: 56,
      ),
    );
  }
}
