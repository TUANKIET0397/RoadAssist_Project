import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/providers/auth_provider.dart';
import 'package:road_assist/core/providers/garage_notification_provider.dart';
import 'package:road_assist/data/datasources/local/vehicle_constants.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';
import 'package:road_assist/ui/garage/home/view/garage_rescue_status_update_screen.dart';
import 'package:road_assist/ui/garage/home/viewmodel/garage_distance_vm.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_viewmodel.dart';
import 'package:road_assist/ui/garage/home/viewmodel/garage_home_viewmodel.dart';

class GarageRescueRequestDetailScreen extends ConsumerStatefulWidget {
  final String rescueRequestId;
  final Function()? onBack;

  const GarageRescueRequestDetailScreen({
    super.key,
    required this.rescueRequestId,
    this.onBack,
  });

  @override
  ConsumerState<GarageRescueRequestDetailScreen> createState() =>
      _GarageRescueRequestDetailScreenState();
}

class _GarageRescueRequestDetailScreenState
    extends ConsumerState<GarageRescueRequestDetailScreen> {
  bool isAccepting = false;
  bool isRejecting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(garageHomeViewModelProvider.notifier)
          .initGarageLocation();
    });
  }


  Future<void> _acceptRequest() async {
    setState(() => isAccepting = true);

    try {
      final userId = ref.read(userIdProvider);
      print('[GARAGE ACCEPT] Starting accept with userId: $userId');
      
      // Lấy full garage info (name + phone) từ FutureProvider
      final garageInfo = await ref.read(currentGarageInfoFutureProvider.future);
      print('[GARAGE ACCEPT] Raw garageInfo from provider: $garageInfo');
      
      final garageName = garageInfo?['name'] ?? 'Garage';
      final garagePhone = garageInfo?['phone'] ?? 'N/A';
      print('[GARAGE ACCEPT] Extracted - garageName: $garageName, garagePhone: $garagePhone');
      
      final repo = ref.read(rescueRequestRepoProvider);

      final success = await repo.acceptRescueRequest(
        requestId: widget.rescueRequestId,
        garageId: userId ?? 'unknown_garage',
        garageName: garageName,
        garagePhone: garagePhone,
      );

      if (success && mounted) {
        // Mark notification đã được accepted
        await ref.read(notificationActionProvider).markNotificationAccepted(
          garageId: userId ?? 'unknown_garage',
          rescueRequestId: widget.rescueRequestId,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã chấp nhận yêu cầu cứu hộ')),
        );
        
        // Lấy request data để chuyển qua màn hình cập nhật trạng thái
        final rescueRequest = ref.read(currentRescueRequestProvider(widget.rescueRequestId));
        
        if (mounted) {
          rescueRequest.when(
            data: (request) { 
              if (request != null && mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => GarageRescueStatusUpdateScreen(
                      rescueRequestId: widget.rescueRequestId,
                      request: request,
                    ),
                  ),
                );
              }
            },
            loading: () {
              // Đợi data load xong
              Navigator.of(context).pop();
            },
            error: (error, st) {
              Navigator.of(context).pop();
            },
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Lỗi chấp nhận yêu cầu')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isAccepting = false);
      }
    }
  }

  /// Từ chối yêu cầu - CHỈ xóa notification của garage này
  /// Không ảnh hưởng đến các garage khác
  Future<void> _rejectRequest() async {
    setState(() => isRejecting = true);

    try {
      final userId = ref.read(userIdProvider);
      debugPrint('[GARAGE REJECT] Rejecting request for garage: $userId');

      // Chỉ xóa notification của garage này
      // KHÔNG thay đổi status của rescue_request
      await ref.read(notificationActionProvider).rejectNotification(
        garageId: userId ?? 'unknown_garage',
        rescueRequestId: widget.rescueRequestId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã từ chối yêu cầu')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isRejecting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem có phải mock request không
    final isMockRequest = widget.rescueRequestId.startsWith('mock_');

    // Dùng mock provider nếu là mock request, ngược lại dùng real provider
    if (isMockRequest) {
      // Mock data - synchronous
      final mockRequest = ref.watch(
        mockCurrentRescueRequestProvider(widget.rescueRequestId),
      );

      return Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết yêu cầu'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Pop route để quay lại Dashboard
              Navigator.of(context).pop();
            },
          ),
        ),
        body: mockRequest == null
            ? const Center(child: Text('Không tìm thấy yêu cầu'))
            : _buildContent(context, mockRequest),
      );
    }

    // Real data - async
    final rescueRequest = ref.watch(
      currentRescueRequestProvider(widget.rescueRequestId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết yêu cầu'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Pop route để quay lại Dashboard
            Navigator.of(context).pop();
          },
        ),
      ),
      body: rescueRequest.when(
        data: (request) {
          if (request == null) {
            return const Center(child: Text('Không tìm thấy yêu cầu'));
          }
          return _buildContent(context, request);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, st) => Center(child: Text('Lỗi: $error')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, RescueRequestModel request) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserHeader(request),
                  const SizedBox(height: 16),

                  _buildVehicleSection(request),
                  const SizedBox(height: 16),

                  _buildIssuesSection(request),
                  const SizedBox(height: 16),

                  _buildLocationSection(request),
                  const SizedBox(height: 16),

                  _buildImageSection(request),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildUserHeader(RescueRequestModel request) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF19253B),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundImage: AssetImage('assets/images/icons/user.png'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      request.userPhone,
                      style: TextStyle(
                        color: Colors.blue.shade300,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.phone, size: 14, color: Colors.green),
                  ],
                ),
              ],
            ),
          ),
          Image.asset(
            kVehicleImages[request.vehicleType] ?? 'assets/images/illustrations/vehicle.png',
            width: 70,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSection(RescueRequestModel request) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Phương tiện người dùng'),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color.fromARGB(255, 30, 183, 140),
              ),
            ),
            child: Text(
              '${request.vehicleType} (${request.vehicleModel})',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssuesSection(RescueRequestModel request) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Thông tin phương tiện'),
          const SizedBox(height: 12),

          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: request.issues.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final issue = request.issues[index];
                return Chip(
                  label: Text(issue),
                  backgroundColor: const Color(0xFF001029),
                  labelStyle: const TextStyle(color: Colors.white),
                  side: BorderSide(color: Colors.blue.shade300, width: 1),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(RescueRequestModel request) {
    final garageState = ref.watch(garageHomeViewModelProvider);

    final distanceKm = ref
        .read(garageHomeViewModelProvider.notifier)
        .calculateDistanceToRequest(request);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF34C8E8),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Địa điểm cứu hộ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Color(0xFF34C8E8),
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(text: request.location),
                      const TextSpan(text: ' '),

                      /// 🔥 HIỂN THỊ KHOẢNG CÁCH
                      TextSpan(
                        text: garageState.isLoading
                            ? '(Đang lấy vị trí garage...)'
                            : distanceKm == null
                            ? '(Không xác định khoảng cách)'
                            : '(Cách bạn ${distanceKm.toStringAsFixed(1)} km)',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/illustrations/map.png',
              height: 70,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 16),

          Center(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF4B4CED)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    colors: [
                      Color(0xFF4B55ED),
                      Color(0xFFFC5C72),
                      Color(0xFFFBFF00),
                      Color(0xFF4B4CED),
                      Color(0xFF4B4CED),
                      Color(0xFF3CD69E),
                      Color(0xFFFC5C72),
                    ],
                  ).createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  );
                },
                child: const Text(
                  'Google Map',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(RescueRequestModel request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Hình ảnh tình trạng xe'),
        const SizedBox(height: 8),

        if (request.imageUrl != null && request.imageUrl!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              request.imageUrl!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black26,
            ),
            child: const Center(
              child: Text(
                'Vui lòng kiểm tra kỹ\ntrước khi nhận',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF18243A)),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: isRejecting ? null : _rejectRequest,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(106, 198, 14, 14),
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 9),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: isRejecting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Từ chối'),
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
            child: TextButton(
              onPressed: isAccepting ? null : _acceptRequest,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(197, 68, 137, 255),
                side: const BorderSide(
                  color: Color.fromARGB(255, 68, 255, 134),
                ),
                padding: const EdgeInsets.symmetric(vertical: 9),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text(
                'Nhận cứu hộ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child, BoxDecoration? decoration}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(7),
      decoration:
          decoration ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF19253B),
          ),
      child: child,
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
  }
}
