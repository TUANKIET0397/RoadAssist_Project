import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:road_assist/ui/account/viewmodel/profile_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a2540),
              Color.fromARGB(255, 223, 97, 23),
              Color(0xFF0f1b2e),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildProfileCard(vm),
              const SizedBox(height: 30),
              _buildForm(vm),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 20, 30, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Thông tin cá nhân',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          _gradientIconButton(Icons.edit_rounded),
        ],
      ),
    );
  }

  // ================= PROFILE CARD =================
  Widget _buildProfileCard(ProfileViewModel vm) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      decoration: _gradientBorder(),
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            _buildAvatar(vm.profile.isVerified),
            const SizedBox(width: 16),
            Expanded(child: _buildProfileInfo(vm)),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isVerified) {
    return Stack(
      children: [
        Container(
          width: 75,
          height: 75,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF7B6EFF), Color(0xFF5548D9)],
            ),
          ),
          child: const Icon(Icons.person, size: 48, color: Colors.white70),
        ),
        if (isVerified)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xFF00D26A),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1a2845), width: 2),
              ),
              child: const Icon(Icons.check, size: 16, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileInfo(ProfileViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${vm.profile.firstName} ${vm.profile.lastName}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              vm.profile.phone,
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit, size: 16, color: Color(0xFF5EC8F2)),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Thêm Email',
          style: TextStyle(
            color: Color(0xFFFF3B57),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ================= FORM =================
  Widget _buildForm(ProfileViewModel vm) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _glassField(
                    label: 'Họ',
                    controller: vm.firstNameController,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _glassField(
                    label: 'Tên',
                    controller: vm.lastNameController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _glassField(
                    label: 'Ngày sinh',
                    controller: vm.birthDateController,
                    suffixIcon: Icons.calendar_today_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _glassField(
                    label: 'SĐT',
                    controller: vm.phoneController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _glassField(label: 'Email', controller: vm.emailController),
            const SizedBox(height: 20),
            _glassField(label: 'Địa chỉ', controller: vm.addressController),
            const SizedBox(height: 40),
            _saveButton(vm),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ================= GLASS FIELD =================
  Widget _glassField({
    required String label,
    required TextEditingController controller,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: GradientBoxBorder(
              gradient: const LinearGradient(
                colors: [Colors.white54, Colors.white24, Color(0xFF5EC8F2)],
              ),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  suffixIcon: suffixIcon != null
                      ? Icon(suffixIcon, color: Colors.white70, size: 20)
                      : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================= SAVE BUTTON =================
  Widget _saveButton(ProfileViewModel vm) {
    return SizedBox(
      width: 240,
      height: 55,
      child: ElevatedButton(
        onPressed: vm.saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5B7EFF), Color(0xFF4B5FED)],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Center(
            child: Text(
              'Lưu thông tin',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= BOTTOM NAV =================
  Widget _buildBottomNavigationBar() {
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1e2d47), Color(0xFF19253d)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _NavItem(Icons.chat_bubble_outline, 'Chat', false),
          _NavItem(Icons.warehouse_outlined, 'Garage', false),
          _NavItem(Icons.pedal_bike_outlined, 'Trang chủ', false),
          _NavItem(Icons.description_outlined, 'Lịch sử', false),
          _NavItem(Icons.person_outline, 'Tài khoản', true),
        ],
      ),
    );
  }

  // ================= DECORATIONS =================
  BoxDecoration _gradientBorder() => BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    gradient: const LinearGradient(
      colors: [Color(0xFF00D9FF), Color(0xFF0088CC)],
    ),
  );

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: const Color(0xFF1a2845),
    borderRadius: BorderRadius.circular(18),
  );

  Widget _gradientIconButton(IconData icon) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5EC8F2), Color(0xFF4E7EF7)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}

// ================= NAV ITEM =================
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem(this.icon, this.label, this.active);

  @override
  Widget build(BuildContext context) {
    return active
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5EC8F2), Color(0xFF4E7EF7)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white54),
              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          );
  }
}
