import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:road_assist/ui/map/location_pick_result.dart';
import 'package:road_assist/ui/map/map_pick_screen.dart';
import 'package:road_assist/ui/user/account/model/vehicle_model.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_viewmodel.dart';
import 'package:road_assist/core/services/gps/location_geolocator.dart';
import 'package:road_assist/core/providers/auth_provider.dart';
import 'package:road_assist/data/datasources/local/vehicle_constants.dart';

class RescueRequestScreen extends ConsumerStatefulWidget {
  final void Function(String requestId) onNavigateToWaiting;

  const RescueRequestScreen({super.key, required this.onNavigateToWaiting});

  @override
  ConsumerState<RescueRequestScreen> createState() =>
      _RescueRequestScreenState();
}

class _RescueRequestScreenState extends ConsumerState<RescueRequestScreen> {
  // Selected options
  String selectedVehicleType = '';
  List<String> selectedIssues = [];
  List<File> selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  // Location
  double? currentLat;
  double? currentLng;
  String? currentAddress;
  bool isLoadingLocation = true;

  // Issues
  final List<String> issues = [
    'Hết xăng',
    'Bể lốp',
    'Mất chìa khóa',
    'Hư máy',
    'Vận chuyển xe',
    'Xẹp lốp',
    'Không rõ nguyên nhân',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialLocation();
  }

  Future<void> _loadInitialLocation() async {
    if (!mounted) return;
    setState(() {
      isLoadingLocation = true;
      currentAddress = 'Đang lấy vị trí...';
    });

    try {
      final position = await LocationService.getCurrentPosition();
      final address = await LocationService.getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;
      setState(() {
        currentLat = position.latitude;
        currentLng = position.longitude;
        currentAddress = address;
        isLoadingLocation = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        currentAddress = e.toString().replaceFirst('Exception: ', '');
        isLoadingLocation = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;
    // {
    //   setState(() {
    //     selectedImages.add(File(image.path));
    //   });
    // }

    // if (selectedImages.length >= 1) return;

    if (!mounted) return;
    setState(() {
      selectedImages
        ..clear()
        ..add(File(image.path));
    });
  }

  void _showVehicleSelector(List<Vehicle> vehicles) {
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
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chọn xe của bạn',
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
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    return ListTile(
                      leading: Container(
                        width: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: AssetImage(
                              kVehicleImages[vehicle.type] ?? 'assets/images/illustrations/vehicle.png',
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      title: Text(
                        vehicle.type,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        vehicle.description ?? 'Model mặc định',
                        style: TextStyle(color: Colors.blue.shade200),
                      ),
                      trailing: Radio<String>(
                        value: vehicle.type,
                        groupValue: selectedVehicleType,
                        onChanged: (value) {
                          setState(() {
                            selectedVehicleType = value!;
                          });
                          Navigator.pop(context);
                        },
                        activeColor: Colors.blue,
                      ),
                      onTap: () {
                        setState(() {
                          selectedVehicleType = vehicle.type;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendRequest() async {
    final userId = ref.read(userIdProvider);

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bạn chưa đăng nhập!')));
      return;
    }

    if (currentLat == null || currentLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng xác định vị trí trước!')),
      );
      return;
    }
    if (selectedIssues.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 vấn đề')),
      );
      return;
    }

    // Lấy user info từ FutureProvider
    final userInfo = await ref.read(currentUserInfoFutureProvider.future);
    final userName = userInfo?['name'] ?? 'User';
    final userPhone = userInfo?['phone'] ?? 'N/A';
    final vehiclesAsync = ref.read(currentUserVehiclesProvider);
    
    final vehicles = vehiclesAsync.value ?? [];
    final currentVehicle = vehicles.firstWhere(
      (v) => v.type == selectedVehicleType,
      orElse: () => Vehicle(type: selectedVehicleType, description: 'Model mặc định'),
    );

    final repo = ref.read(rescueRequestRepoProvider);

    final id = await repo.createRescueRequest(
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      vehicleType: selectedVehicleType,
      vehicleModel: currentVehicle.description ?? 'Model mặc định',
      issues: selectedIssues,
      location: currentAddress!,
      latitude: currentLat!,
      longitude: currentLng!,
      image: selectedImages.isNotEmpty ? selectedImages.first : null,
    );

    if (id != null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gửi yêu cầu thành công!')));
        setState(() {
          selectedIssues.clear();
          selectedImages.clear();
        });
        widget.onNavigateToWaiting(id);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gửi yêu cầu thất bại!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(currentUserVehiclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Gọi cứu hộ'),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: Icon(Icons.error_outline, color: Colors.red, size: 32),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(56, 56, 224, 1),
              Color.fromRGBO(46, 144, 183, 1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      const Text(
                        'Vui lòng mô tả tình trạng xe',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Vehicle Selection
                      vehiclesAsync.when(
                        data: (vehicles) {
                          if (vehicles.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha:  0.3),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'Không có xe nào được đăng ký',
                                style: TextStyle(color: Colors.white70),
                              ),
                            );
                          }
                          
                          // Set default vehicle if not selected
                          if (selectedVehicleType.isEmpty && vehicles.isNotEmpty) {
                            selectedVehicleType = vehicles.first.type;
                          }
                          
                          final currentVehicle = vehicles.firstWhere(
                            (v) => v.type == selectedVehicleType,
                            orElse: () => vehicles.first,
                          );
                          
                          return GestureDetector(
                            onTap: () => _showVehicleSelector(vehicles),
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
                                          kVehicleImages[currentVehicle.type] ?? 'assets/images/illustrations/vehicle.png',
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
                                          currentVehicle.type,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          currentVehicle.description ?? 'Model mặc định',
                                          style: const TextStyle(
                                            color: Colors.white54,
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
                        },
                        loading: () => Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, stack) => Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Lỗi: $error',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Issues Selection
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: issues.map((issue) {
                          final isSelected = selectedIssues.contains(issue);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedIssues.remove(issue);
                                } else {
                                  selectedIssues.add(issue);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF008CA8)
                                    : const Color(0xFF001029),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.blue.shade300
                                      : Colors.blue.shade700,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                issue,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Location Section
                      const Text(
                        'Vị trí hiện tại',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          final result =
                              await Navigator.push<LocationPickResult>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MapPickScreen(),
                                ),
                              );

                          if (result != null && mounted) {
                            setState(() {
                              currentLat = result.latitude;
                              currentLng = result.longitude;
                              currentAddress = result.address;
                            });
                          }
                        },

                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF001029),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.blue.shade700,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.map_outlined,
                                    color: Colors.blue.shade300,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      currentAddress ?? 'Đang lấy vị trí...',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(
                                color: Colors.white38,
                                thickness: 1,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.navigation,
                                    color: Colors.blue.shade300,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Chọn / cập nhật vị trí',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Photo Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF001029),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.blue.shade700,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            for (int i = 0; i < selectedImages.length; i++) ...[
                              Expanded(
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        selectedImages[i],
                                        height: 140,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: GestureDetector(
                                        onTap: () {
                                          if (mounted) {
                                            setState(() {
                                              selectedImages.removeAt(i);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (i != selectedImages.length - 1)
                                const SizedBox(width: 12),
                            ],

                            if (selectedImages.length < 2) ...[
                              if (selectedImages.isNotEmpty)
                                const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: const Color(0xFF4B4CED),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Chụp ảnh',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      const Center(
                        child: Text(
                          'Vui lòng đảm bảo vị trí và chụp hình trước khi gửi',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                child: ElevatedButton(
                  onPressed: _sendRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF19253B),
                    minimumSize: const Size(double.infinity, 51),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.blue.shade700, width: 1),
                    ),
                  ),
                  child: const Text(
                    'Gửi yêu cầu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
