import 'package:flutter/material.dart';
import 'package:road_assist/data/datasources/local/vehicle_constants.dart';
import 'package:road_assist/ui/user/account/model/vehicle_model.dart';

/// Widget hiển thị và chọn loại xe
class RescueVehicleSelector extends StatelessWidget {
  final String selectedVehicleType;
  final List<Vehicle> vehicles;
  final VoidCallback onTap;

  const RescueVehicleSelector({
    super.key,
    required this.selectedVehicleType,
    required this.vehicles,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Tìm vehicle đã đăng ký (nếu có)
    final registeredVehicle = vehicles.cast<Vehicle?>().firstWhere(
      (v) => v?.type == selectedVehicleType,
      orElse: () => null,
    );
    
    // Kiểm tra xe đã đăng ký hay chưa
    final isRegistered = registeredVehicle != null;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF008CA8),
              Color(0xFF2A3DAA),
              Color(0xFF001029),
            ],
            stops: [0.0, 0.7, 1.0],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.blueAccent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 90,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(
                    kVehicleImages[selectedVehicleType] ?? 'assets/images/illustrations/vehicle.png',
                  ),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedVehicleType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isRegistered 
                        ? (registeredVehicle.description ?? 'Đã đăng ký')
                        : 'Chưa đăng ký',
                    style: TextStyle(
                      color: isRegistered ? Colors.white54 : Colors.orange.shade300,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal bottom sheet để chọn loại xe
class VehicleSelectorBottomSheet extends StatelessWidget {
  final String selectedVehicleType;
  final List<Vehicle> registeredVehicles;
  final ValueChanged<String> onVehicleSelected;

  const VehicleSelectorBottomSheet({
    super.key,
    required this.selectedVehicleType,
    required this.registeredVehicles,
    required this.onVehicleSelected,
  });

  static void show(
    BuildContext context, {
    required String selectedVehicleType,
    required List<Vehicle> registeredVehicles,
    required ValueChanged<String> onVehicleSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1e3a8a),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => VehicleSelectorBottomSheet(
          selectedVehicleType: selectedVehicleType,
          registeredVehicles: registeredVehicles,
          onVehicleSelected: onVehicleSelected,
        )._buildContent(context, scrollController),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ScrollController scrollController) {
    final registeredTypes = registeredVehicles.map((v) => v.type).toSet();
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chọn loại xe',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: kUserVehicleTypes.length,
              itemBuilder: (context, index) {
                final vehicleType = kUserVehicleTypes[index];
                final isRegistered = registeredTypes.contains(vehicleType);
                // Tìm vehicle đã đăng ký để lấy description nếu có
                final registeredVehicle = registeredVehicles.cast<Vehicle?>().firstWhere(
                  (v) => v?.type == vehicleType,
                  orElse: () => null,
                );
                
                return ListTile(
                  leading: Container(
                    width: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(
                          kVehicleImages[vehicleType] ?? 'assets/images/illustrations/vehicle.png',
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  title: Text(
                    vehicleType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    isRegistered 
                        ? (registeredVehicle?.description ?? 'Đã đăng ký')
                        : 'Chưa đăng ký',
                    style: TextStyle(
                      color: isRegistered ? Colors.green.shade300 : Colors.orange.shade300,
                    ),
                  ),
                  trailing: Radio<String>(
                    value: vehicleType,
                    groupValue: selectedVehicleType,
                    onChanged: (value) {
                      onVehicleSelected(value!);
                      Navigator.pop(context);
                    },
                    activeColor: Colors.blue,
                  ),
                  onTap: () {
                    onVehicleSelected(vehicleType);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent(context, ScrollController());
  }
}
