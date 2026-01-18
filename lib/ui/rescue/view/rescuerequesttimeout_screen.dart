import 'package:flutter/material.dart';
import 'package:road_assist/data/models/garage_model.dart';
import 'package:road_assist/ui/rescue/viewmodel/rescuerequesttimeout_vm.dart';

class NoGarageFoundScreen extends StatefulWidget {
  const NoGarageFoundScreen({Key? key}) : super(key: key);

  @override
  State<NoGarageFoundScreen> createState() => _NoGarageFoundScreenState();
}

class _NoGarageFoundScreenState extends State<NoGarageFoundScreen> {
  late NoGarageFoundViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = NoGarageFoundViewModel();
    _viewModel.loadNearbyGarages();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C3E50),
              Color(0xFF34495E),
              Color(0xFF2980B9),
            ],
          ),
        ),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, child) {
              return Column(
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),

                            // Error Illustration - để trống cho bạn thêm hình
                            Container(
                              height: 120,
                              width: 200,
                              child: Center(
                                child: Image.asset(
                                  'assets/images/no_garage_illustration.png',
                                  width: 200,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.warning_amber_rounded,
                                      size: 120,
                                      color: Colors.orange,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),

                            // Title
                            const Text(
                              'Chưa tìm được garage nào phù hợp',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Hiện tại chưa có Garage nào nhận yêu cầu cứu hộ',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 5),

                            // Info Card
                            _buildInfoCard(),
                            const SizedBox(height: 5),

                            // Nearby Garages Section
                            _buildNearbyGaragesSection(),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom Button
                  _buildBottomButton(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B4513).withOpacity(0.6),
            Color(0xFF654321).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Có thể bạn cần',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Đừng lo lắng! Việc chưa tìm được garage phù hợp có thể do các garage gần bạn đang quá tải. Bạn vẫn có thể gọi trực tiếp các garage bên dưới để được hỗ trợ ngay, hoặc thử gửi lại yêu cầu sau khi cập nhật vị trí chính xác hơn.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyGaragesSection() {
    if (_viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.lightBlueAccent,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Garage gần bạn',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        ..._viewModel.nearbyGarages.map((garage) {
          return _buildGarageCard(garage);
        }).toList(),
      ],
    );
  }

  Widget _buildGarageCard(GarageModel garage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Color(0xFF1E3A5F).withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.lightBlueAccent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Garage Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              garage.imageUrl ?? 'assets/images/garage_placeholder.png',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Color(0xFF2C3E50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.garage,
                    size: 35,
                    color: Colors.lightBlueAccent.withOpacity(0.7),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          // Garage Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  garage.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  garage.vehicleTypes.join(', '),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.lightGreenAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${garage.distance} km',
                      style: TextStyle(
                        color: Colors.lightGreenAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Call Button
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.lightBlueAccent,
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _viewModel.callGarage(garage.id),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.phone,
                        color: Colors.lightBlueAccent,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Gọi',
                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Color(0xFF1A2634).withOpacity(0.95),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _viewModel.resendRescueRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
              foregroundColor: Color(0xFF1A2634),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Gửi lại yêu cầu cứu hộ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}