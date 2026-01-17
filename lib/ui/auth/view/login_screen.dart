import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:road_assist/ui/auth/viewmodel/login_viewmodel.dart';
import 'package:road_assist/ui/home/view/home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [Color.fromARGB(255, 1, 23, 103), Color(0xFF1A1E3D)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(height: 60),

                  Image.asset(
                    'assets/images/logos/logo.png',
                    width: 173,
                    height: 155,
                  ),

                  SizedBox(height: 2),

                  // Title
                  Text(
                    'Đăng Nhập',
                    style: TextStyle(
                      color: const Color(0xFF00BFFC),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 2),

                  Text(
                    'Chào mừng bạn đến với RoadAssist',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),

                  SizedBox(height: 40),

                  // Phone Number Input
                  Consumer<LoginViewModel>(
                    builder: (context, viewModel, child) {
                      return _buildInputField(
                        icon: Icons.person_outline,
                        hintText: '+84 9xxxxxxxxxx',
                        onChanged: viewModel.setPhoneNumber,
                        keyboardType: TextInputType.phone,
                      );
                    },
                  ),

                  SizedBox(height: 16),

                  // Password Input
                  Consumer<LoginViewModel>(
                    builder: (context, viewModel, child) {
                      return _buildInputField(
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
                      );
                    },
                  ),

                  SizedBox(height: 16),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Quên mật khẩu?',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Login Button
                  Consumer<LoginViewModel>(
                    builder: (context, viewModel, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: viewModel.isLoading
                              ? null
                              : () async {
                                  final success = await viewModel.login();
                                  if (success) {}
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0D7EFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: viewModel.isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Đăng nhập',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
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

                  SizedBox(height: 24),

                  // Face ID Button
                  Consumer<LoginViewModel>(
                    builder: (context, viewModel, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: viewModel.loginWithFaceId,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: Icon(Icons.face, color: Colors.white),
                          label: Text(
                            'Đăng nhập bằng Face ID',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 24),

                  // Social Login
                  Text(
                    'Hoặc đăng nhập với',
                    style: TextStyle(color: Colors.white54),
                  ),

                  SizedBox(height: 16),

                  Consumer<LoginViewModel>(
                    builder: (context, viewModel, child) {
                      return Row(
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
                              if (user != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
                                  ),
                                );
                              }
                            },
                            color: Colors.red,
                          ),
                          SizedBox(width: 20),
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
                          SizedBox(width: 20),
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
                      );
                    },
                  ),

                  SizedBox(height: 24),

                  // Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Chưa có tài khoản? ',
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Đăng ký ngay',
                          style: TextStyle(
                            color: Color(0xFF0D7EFF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
}
