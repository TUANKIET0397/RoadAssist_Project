import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:road_assist/presentation/views/rescue/viewmodel/rescue_viewmodel.dart';
import 'package:road_assist/services/location_geolocator.dart';
import 'package:road_assist/presentation/views/rescue/map_picker_screen.dart';
import 'package:road_assist/core/providers/auth_provider.dart';

class RescueRequestScreen extends ConsumerStatefulWidget {
  const RescueRequestScreen({super.key});

  @override
  ConsumerState<RescueRequestScreen> createState() =>
      _RescueRequestScreenState();
}

class _RescueRequestScreenState extends ConsumerState<RescueRequestScreen> {
  // Selected options
  String selectedVehicleType = 'Xe tay ga';
  List<String> selectedIssues = [];
  List<File> selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  // Location
  double? currentLat;
  double? currentLng;
  String? currentAddress;
  bool isLoadingLocation = true;

  // Vehicle types
  final List<Map<String, dynamic>> vehicleTypes = [
    {'name': 'Xe tay ga', 'model': 'Honda SH Mode 2025'},
    {'name': 'Xe số', 'model': 'Honda Wave 2024'},
    {'name': 'Xe côn tay', 'model': 'Yamaha Exciter 2025'},
  ];

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
    //_loadInitialLocation();
  }

  Future<void> _loadInitialLocation() async {
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

      setState(() {
        currentLat = position.latitude;
        currentLng = position.longitude;
        currentAddress = address;
        isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        currentAddress = e.toString().replaceFirst('Exception: ', '');
        isLoadingLocation = false;
      });
    }
  }

  Future<void> _pickImage() async {
    if (selectedImages.length >= 2) return;

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImages.add(File(image.path));
      });
    }
  }

  void _showVehicleSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1e3a8a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            ...vehicleTypes.map(
              (vehicle) => ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(
                  vehicle['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  vehicle['model'],
                  style: TextStyle(color: Colors.blue.shade200),
                ),
                trailing: Radio<String>(
                  value: vehicle['name'],
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
                    selectedVehicleType = vehicle['name'];
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
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
    //
    // if (currentLat == null || currentLng == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Vui lòng xác định vị trí trước!')),
    //   );
    //   return;
    // }
    if (selectedIssues.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 vấn đề')),
      );
      return;
    }

    // Hard code vị trí tạm thời
    final testLat = 10.762622; // VD: TP.HCM
    final testLng = 106.660172;
    final testAddress = 'TP.Hồ Chí Minh, Việt Nam';

    final repo = ref.read(rescueRequestRepoProvider);

    final id = await repo.createRescueRequest(
      userId: userId,
      userName: 'Nguyen Gia Bao',
      userPhone: '0123456789',
      vehicleType: selectedVehicleType,
      vehicleModel: vehicleTypes.firstWhere(
        (v) => v['name'] == selectedVehicleType,
      )['model'],
      issues: selectedIssues,
      location: testAddress,
      latitude: testLat,
      longitude: testLng,
      image: selectedImages.isNotEmpty ? selectedImages.first : null,
    );

    if (id != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gửi yêu cầu thành công!')));
      setState(() {
        selectedIssues.clear();
        selectedImages.clear();
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gửi yêu cầu thất bại!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentVehicle = vehicleTypes.firstWhere(
      (v) => v['name'] == selectedVehicleType,
      orElse: () => vehicleTypes[0],
    );

    return Scaffold(
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
              // Header
              Container(
                color: const Color.fromRGBO(37, 44, 59, 1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Gọi cứu hộ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

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
                      GestureDetector(
                        onTap: _showVehicleSelector,
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
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: const DecorationImage(
                                    image: NetworkImage(
                                      'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentVehicle['name'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      currentVehicle['model'],
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
                        onTap: () async {},
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
                              Divider(color: Colors.white38, thickness: 1),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
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
                                          setState(() {
                                            selectedImages.removeAt(i);
                                          });
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
                                          'Thêm ảnh',
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
                      const SizedBox(height: 16),

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
                padding: const EdgeInsets.all(16.0),
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
