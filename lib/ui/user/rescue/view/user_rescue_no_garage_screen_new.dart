import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/garage_model.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_navigation_provider.dart';

class UserRescueNoGarageScreen extends ConsumerWidget {
  final String? rescueRequestId;
  final List<GarageModel> scannedGarages;

  const UserRescueNoGarageScreen({
    super.key,
    this.rescueRequestId,
    required this.scannedGarages,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Không tìm được garage'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0f172a),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1e3a8a),
              Color(0xFF0f172a),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: Column(
                        children: [
                          // Hình ảnh minh hoạ - xử lý lỗi nếu asset không tồn tại
                          SizedBox(
                            height: 140,
                            child: Image.asset(
                              'assets/images/illustrations/no_garage.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade900,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.local_gas_station,
                                    size: 80,
                                    color: Colors.blue.shade300,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Chưa tìm được garage nào phù hợp',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Hiện tại chưa có Garage nào nhận yêu cầu cứu hộ',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF92400E), Color(0xFFEA580C)],
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Có thể bạn cần',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Đừng lo lắng! Việc chưa tìm được garage phù hợp có thể do các garage gần bạn đang quá tải. '
                            'Bạn vẫn có thể gọi trực tiếp các garage bên dưới để được hỗ trợ ngay, '
                            'hoặc thử gửi lại yêu cầu sau khi cập nhật vị trí chính xác hơn.',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Garage gần bạn',
                        style: TextStyle(
                          color: Colors.blue.shade200,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Hiển thị garage đã quét được hoặc thông báo không có
                    if (scannedGarages.isEmpty) ...[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF020617),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'Không có garage nào gần bạn trong lúc này.\nVui lòng thử lại sau hoặc liên hệ trực tiếp.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ] else ...[
                      // Container với ListView có thể scroll cho danh sách garage
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        height: scannedGarages.length > 3 ? 240 : null, // Chiều cao cố định nếu > 3 garage
                        child: scannedGarages.length > 3 
                          ? ListView.builder(
                              itemCount: scannedGarages.length,
                              itemBuilder: (context, index) {
                                final garage = scannedGarages[index];
                                return _garageItem(
                                  name: garage.name,
                                  type: garage.vehicleTypes.isNotEmpty 
                                      ? garage.vehicleTypes.join(', ') 
                                      : 'Đa dạng phương tiện',
                                  distance: garage.distance != null 
                                      ? '${garage.distance!.toStringAsFixed(1)} km'
                                      : 'N/A',
                                  phone: garage.phone,
                                );
                              },
                            )
                          : Column(
                              children: scannedGarages.map((garage) => _garageItem(
                                name: garage.name,
                                type: garage.vehicleTypes.isNotEmpty 
                                    ? garage.vehicleTypes.join(', ') 
                                    : 'Đa dạng phương tiện',
                                distance: garage.distance != null 
                                    ? '${garage.distance!.toStringAsFixed(1)} km'
                                    : 'N/A',
                                phone: garage.phone,
                              )).toList(),
                            ),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleRetryRequest(context, ref),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.cyanAccent.shade400,
                  ),
                  child: const Text(
                    'Gửi lại yêu cầu cứu hộ',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRetryRequest(BuildContext context, WidgetRef ref) {
    ref.read(rescueNavigationProvider.notifier).backToRequest();
  }
}

Widget _garageItem({
  required String name, 
  required String type, 
  required String distance, 
  required String phone
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8), // Chỉ margin bottom cho spacing
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF020617),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 56,
            height: 56,
            child: Image.asset(
              'assets/images/illustrations/vehicle.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.directions_car,
                    color: Colors.blue.shade300,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                type,
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                '● $distance',
                style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {
            // Xử lý gọi điện thoại
            // Sử dụng package url_launcher để gọi điện
          },
          icon: const Icon(Icons.phone, size: 16),
          label: const Text('Gọi'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blueAccent,
            side: const BorderSide(color: Colors.blueAccent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    ),
  );
}
