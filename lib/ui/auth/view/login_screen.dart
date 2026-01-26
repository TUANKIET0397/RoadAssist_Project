import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:road_assist/core/theme/app_palette.dart';
import 'package:road_assist/ui/auth/viewmodel/login_viewmodel.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(loginViewModelProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppPalette.bgColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                Image.asset(
                  'assets/images/logos/logo.png',
                  width: 173,
                  height: 155,
                ),

                const SizedBox(height: 2),

                const Text(
                  'Đăng Nhập',
                  style: TextStyle(
                    color: Color(0xFF00BFFC),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                const Text(
                  'Chào mừng bạn đến với RoadAssist',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),

                const SizedBox(height: 40),

                _buildInputField(
                  icon: Icons.person_outline,
                  hintText: '+84 9xxxxxxxxxx',
                  onChanged: viewModel.setPhoneNumber,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 16),

                _buildInputField(
                  icon: Icons.lock_outline,
                  hintText: '••••••••',
                  onChanged: viewModel.setPassword,
                  obscureText: viewModel.obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      viewModel.obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white54,
                    ),
                    onPressed: viewModel.togglePasswordVisibility,
                  ),
                ),

                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Quên mật khẩu?',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            final success = await viewModel.login(ref);
                            if (success && context.mounted) {}
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D7EFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: viewModel.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Đăng nhập',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: const [
                    Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Hoặc',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: viewModel.loginWithFaceId,
                    icon: const Icon(Icons.face, color: Colors.white),
                    label: const Text(
                      'Đăng nhập bằng Face ID',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Hoặc đăng nhập với',
                  style: TextStyle(color: Colors.white54),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      Image.asset(
                        'assets/images/gmail_logo.png',
                        width: 32,
                        height: 32,
                      ),
                      icon: Icons.mail,
                      onTap: () async {
                        final user = await viewModel.loginWithGoogle();
                        if (user != null && context.mounted) {
                          context.go('/home');
                        }
                      },
                      color: Colors.red,
                    ),
                    const SizedBox(width: 20),
                    _buildSocialButton(
                      Image.asset(
                        'assets/images/apple_logo.png',
                        width: 32,
                        height: 32,
                      ),
                      icon: Icons.apple,
                      onTap: viewModel.loginWithApple,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 20),
                    _buildSocialButton(
                      Image.asset(
                        'assets/images/facebook_logo.png',
                        width: 32,
                        height: 32,
                      ),
                      icon: Icons.facebook,
                      onTap: viewModel.loginWithFacebook,
                      color: Colors.blue,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Chưa có tài khoản? ',
                      style: TextStyle(color: Colors.white70),
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/auth/user/register');
                      },
                      child: const Text(
                        'Đăng ký ngay',
                        style: TextStyle(
                          color: Color(0xFF00D4FF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
          
          // Nút mũi tên ngược cố định ở góc trái
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context.go('/auth/role');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

Widget _buildInputField({
  required IconData icon,
  required String hintText,
  required Function(String) onChanged,
  bool obscureText = false,
  Widget? suffixIcon,
  TextInputType? keyboardType,
}) {
  return Container(
    decoration: BoxDecoration(
      // ignore: deprecated_member_use
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.2),
        width: 1,
      ),
    ),
    child: TextField(
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white54),
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white54),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    ),
  );
}

Widget _buildSocialButton(
  Image image, {
  required IconData icon,
  required VoidCallback onTap,
  required Color color,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Icon(icon, color: color, size: 32),
    ),
  );
}
