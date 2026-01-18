import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';
import 'package:road_assist/ui/rescue/viewmodel/rescue_success_viewmodel.dart';

class RescueSuccessScreen extends ConsumerWidget {
  const RescueSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rescueSuccessProvider);
    final notifier = ref.read(rescueSuccessProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C3E50), Color(0xFF1A2634), Color(0xFF0D1B2A)],
          ),
        ),
        child: SafeArea(
          child: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.lightBlueAccent,
                  ),
                )
              : state.rescueRequest == null
              ? const Center(
                  child: Text(
                    'Không có dữ liệu',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),

                        Image.asset(
                          'assets/images/success.png',
                          width: 125,
                          height: 145,
                        ),

                        const Text(
                          'Gửi yêu cầu cứu hộ thành công',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        _buildVehicleCard(state.rescueRequest!),
                        _buildStatusCard(state.rescueRequest!),
                        _buildContactCard(state.rescueRequest!),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: notifier.trackRescueStatus,
                            child: const Text('Theo dõi trạng thái cứu hộ'),
                          ),
                        ),

                        TextButton(
                          onPressed: notifier.chatWithGarage,
                          child: const Text('Chat với garage'),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
 Widget _buildVehicleCard(RescueRequestModel request) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF020617)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.lightBlueAccent.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.lightBlueAccent.withOpacity(0.35),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/xe_ga.png',
                width: 100,
                height: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 16),

              SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.vehicleType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.vehicleModel,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 2),

          /// ===== HÀNG 2: SERVICES =====
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: request.issues.map((service) {
              return InkWell(
                onTap: () {
                  print('Bạn đã nhấn vào: $service');
                },
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.lightBlueAccent, width: 1),
                    color: Colors.lightBlueAccent.withOpacity(0.1),
                  ),
                  child: Text(
                    service,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(RescueRequestModel request) {
    return Container(
      padding: const EdgeInsets.only(left: 3, top: 6, right: 3, bottom: 6),
      decoration: BoxDecoration(
        color: Color(0xFF1E3A8A).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.lightBlueAccent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: request.statusUpdates.map((status) {
          final index = request.statusUpdates.indexOf(status);
          final isFirst = index == 0;
          // Kiểm tra xem đây có phải phần tử cuối cùng không
          final isLast = index == request.statusUpdates.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF040080), // Màu nền vòng tròn
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(2), // Độ dày của viền
                  child: const Icon(
                    Icons.check, // Chỉ lấy dấu tick
                    color: Color(0xFF6768F6), // Màu của dấu tick
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isFirst ? Colors.lightBlueAccent : Colors.white70,
                      fontSize: 16,
                      fontWeight: isFirst ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContactCard(RescueRequestModel request) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color(0xFF1E3A8A).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.lightBlueAccent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vị trí của bạn',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.lightBlueAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  request.location,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          InkWell(
            onTap: () {
              // Thêm logic gọi điện ở đây (ví dụ dùng package url_launcher)
              print('Đang gọi đến: ${request.userPhone}');
            },
            borderRadius: BorderRadius.circular(
              12,
            ),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFF2C3E50),
                borderRadius: BorderRadius.circular(12),
                // Thêm một chút viền nhẹ để nút nổi bật hơn
                border: GradientBoxBorder(  
                  gradient:LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    const Color.fromARGB(255, 9, 130, 187),
                    const Color.fromARGB(0, 248, 248, 248),
                  ],
                ),
                  width: 1.5,
              ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.phone,
                    color: Colors.lightBlueAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    request.userPhone,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600, // Tăng độ đậm một chút cho giống nút
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

