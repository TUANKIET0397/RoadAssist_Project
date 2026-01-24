import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:road_assist/core/routes/route_paths.dart';

class AuthRoleScreen extends StatelessWidget {
  const AuthRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),

              // ===== TITLE =====
              const Text(
                'Chào mừng bạn 👋',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              const Text(
                'Bạn muốn đăng nhập với vai trò nào?',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // ===== USER ROLE =====
              _RoleCard(
                icon: Icons.person,
                title: 'Người dùng',
                subtitle: 'Tìm garage, chat, lịch sử cứu hộ',
                onTap: () {
                  context.go(RoutePaths.userLogin);
                },
              ),

              const SizedBox(height: 16),

              // ===== GARAGE ROLE =====
              _RoleCard(
                icon: Icons.store,
                title: 'Garage',
                subtitle: 'Nhận yêu cầu, quản lý dịch vụ',
                onTap: () {
                  context.go(RoutePaths.garageLogin);
                },
              ),

              const Spacer(),

              const Text(
                'Bạn có thể thay đổi vai trò sau khi đăng xuất',
                style: TextStyle(fontSize: 13, color: Colors.black45),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 1, 1, 1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF34C8E8).withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 30, color: const Color(0xFF34C8E8)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}
