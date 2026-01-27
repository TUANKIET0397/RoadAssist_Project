import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:road_assist/core/theme/app_palette.dart';
import 'package:road_assist/core/providers/auth_provider.dart';

import 'package:road_assist/ui/garage/account/view/search_screen.dart';
import 'package:road_assist/ui/garage/account/viewmodel/garage_vm.dart';
import 'package:road_assist/ui/garage/account/widgets/action_button.dart';
import 'package:road_assist/ui/garage/account/widgets/vehicle_support_item.dart';
import 'package:road_assist/ui/garage/account/widgets/add_vehicle_dialog.dart';
import 'package:road_assist/ui/garage/home/viewmodel/garage_home_viewmodel.dart'
    as vm;
import 'package:road_assist/ui/user/account/widgets/logout_button.dart';

import '../widgets/garage_card.dart';

class GarageAccountScreen extends ConsumerStatefulWidget {
  const GarageAccountScreen({super.key});

  @override
  ConsumerState<GarageAccountScreen> createState() =>
      _GarageAccountScreenState();
}

class _GarageAccountScreenState extends ConsumerState<GarageAccountScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);

    if (!auth.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!auth.isLoggedIn || auth.userId == null) {
      return const Scaffold(body: Center(child: Text('Chưa đăng nhập')));
    }

    final userId = auth.userId!;
    final state = ref.watch(garageProvider(userId));
    final garage = state.savedGarage;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trang Garage',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
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
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ],
        backgroundColor: colorScheme.surface,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppPalette.bgColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : garage.id.isEmpty
            ? _buildEmptyState(context)
            : _buildGarageContent(context, userId, state, garage),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.garage, size: 80, color: Colors.white24),
          const SizedBox(height: 16),
          const Text(
            'Chưa có thông tin garage',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.push('/garage/account/info');
            },
            child: const Text('Tạo thông tin garage'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              final userId = ref.read(authStateProvider).userId!;
              ref.read(garageProvider(userId).notifier).refresh();
            },
            child: const Text(
              'Làm mới',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGarageContent(
    BuildContext context,
    String userId,
    dynamic state,
    dynamic garage,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(garageProvider(userId).notifier).refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            GarageCard(garage: garage),
            const SizedBox(height: 18),
            _buildVehicleTypesSection(context, userId, garage),
            const SizedBox(height: 18),
            const Text(
              'Cứu hộ & hoạt động',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            _buildActionButtons(context),
            LogoutButton(onTap: vm.logout),
            const SizedBox(height: 150),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleTypesSection(
    BuildContext context,
    String userId,
    dynamic garage,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Loại Phương Tiện Hỗ trợ',
              style: TextStyle(
                color: Color.fromRGBO(127, 199, 252, 1),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF4FC3F7),
                size: 28,
              ),
              onPressed: () => _showAddVehicleDialog(context, userId, garage),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (garage.vehicleTypes.isEmpty)
          const Center(
            child: Text(
              'Chưa có loại phương tiện',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          )
        else
          ...garage.vehicleTypes.map(
            (vehicle) => VehicleSupportItem(
              name: vehicle,
              onAdd: () =>
                  _handleRemoveVehicle(context, userId, garage, vehicle),
            ),
          ),
      ],
    );
  }

  void _showAddVehicleDialog(
    BuildContext context,
    String userId,
    dynamic garage,
  ) {
    showDialog(
      context: context,
      builder: (_) => AddVehicleDialog(
        existingVehicles: garage.vehicleTypes,
        onAdd: (vehicleType) async {
          await ref
              .read(garageProvider(userId).notifier)
              .addVehicleType(garageId: garage.id, vehicleType: vehicleType);

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm $vehicleType'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleRemoveVehicle(
    BuildContext context,
    String userId,
    dynamic garage,
    String vehicle,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A38),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF4FC3F7), width: 2),
        ),
        title: const Text(
          'Xác nhận xóa',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Bạn có chắc muốn xóa "$vehicle"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    await ref
        .read(garageProvider(userId).notifier)
        .removeVehicleType(garageId: garage.id, vehicleType: vehicle);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã xóa $vehicle'), backgroundColor: Colors.green),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 16,
      childAspectRatio: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ActionButton(
          icon: Icons.search,
          label: 'Các cuộc cứu hộ',
          onTap: () {
            context.push('/garage/home');
          },
        ),
        ActionButton(
          icon: Icons.favorite,
          label: 'Đánh Giá',
          onTap: () => context.go('/garage/review'),
        ),
        ActionButton(
          icon: Icons.info,
          label: 'Thông tin Garage',
          onTap: () => context.push('/garage/account/info'),
        ),
        ActionButton(
          icon: Icons.lock,
          label: 'Đổi mật khẩu',
          onTap: () => context.push('/garage/account/passwordreset'),
        ),
      ],
    );
  }
}
