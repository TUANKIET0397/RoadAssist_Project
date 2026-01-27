import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:road_assist/ui/map/location_pick_result.dart';
import 'package:road_assist/ui/map/map_pick_screen.dart';
import 'package:road_assist/ui/user/account/model/vehicle_model.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_viewmodel.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_navigation_provider.dart';
import 'package:road_assist/core/services/gps/location_geolocator.dart';
import 'package:road_assist/core/providers/auth_provider.dart';
import 'package:road_assist/data/datasources/local/vehicle_constants.dart';
import 'package:road_assist/ui/user/home/viewmodel/home_vehicle_provider.dart';
import 'package:road_assist/ui/user/rescue/widgets/rescue_vehicle_selector.dart';
import 'package:road_assist/ui/user/rescue/widgets/rescue_issue_selector.dart';
import 'package:road_assist/ui/user/rescue/widgets/rescue_location_picker.dart';
import 'package:road_assist/ui/user/rescue/widgets/rescue_image_picker.dart';

class RescueRequestScreen extends ConsumerStatefulWidget {
  const RescueRequestScreen({super.key});

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
    // Delay loading pre-selected values until after the first frame
    // to avoid modifying provider during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPreSelectedValues();
    });
  }

  /// Load pre-selected vehicle type and issue from providers (if any)
  void _loadPreSelectedValues() {
    if (!mounted) return;

    // Read pre-selected vehicle type
    final preSelectedVehicle = ref.read(preSelectedVehicleTypeProvider);
    if (preSelectedVehicle != null && preSelectedVehicle.isNotEmpty) {
      setState(() {
        selectedVehicleType = preSelectedVehicle;
      });
      // Clear the provider after reading
      ref.read(preSelectedVehicleTypeProvider.notifier).state = null;
    }

    // Read pre-selected issue
    final preSelectedIssue = ref.read(preSelectedIssueProvider);
    if (preSelectedIssue != null && preSelectedIssue.isNotEmpty) {
      setState(() {
        selectedIssues = [preSelectedIssue];
      });
      // Clear the provider after reading
      ref.read(preSelectedIssueProvider.notifier).state = null;
    }
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
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );
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
    final vehiclesAsync = ref.read(allUserVehiclesProvider);

    final vehicles = vehiclesAsync.value ?? [];
    final currentVehicle = vehicles.firstWhere(
      (v) => v.type == selectedVehicleType,
      orElse: () =>
          Vehicle(type: selectedVehicleType, description: 'Model mặc định'),
    );

    final repo = ref.read(rescueRequestRepoProvider);

    debugPrint('🔥 === CREATING RESCUE REQUEST ===');
    debugPrint('👤 User: $userName ($userId)');
    debugPrint('📱 Phone: $userPhone');
    debugPrint(
      '🚗 Vehicle: $selectedVehicleType - ${currentVehicle.description}',
    );
    debugPrint('📍 Location: $currentAddress');
    debugPrint('🌍 Coordinates: lat=$currentLat, lng=$currentLng');
    debugPrint('❗ Issues: $selectedIssues');

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gửi yêu cầu thành công!')),
        );
        setState(() {
          selectedIssues.clear();
          selectedImages.clear();
        });
        // Sử dụng provider thay vì callback
        ref.read(rescueNavigationProvider.notifier).navigateToWaiting(id);
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
    final vehiclesAsync = ref.watch(allUserVehiclesProvider);

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
                          // Nếu chưa chọn xe và có xe đã đăng ký -> chọn xe đầu tiên
                          // Nếu chưa chọn xe và không có xe đăng ký -> chọn xe đầu tiên từ kUserVehicleTypes
                          if (selectedVehicleType.isEmpty) {
                            if (vehicles.isNotEmpty) {
                              selectedVehicleType = vehicles.first.type;
                            } else if (kUserVehicleTypes.isNotEmpty) {
                              selectedVehicleType = kUserVehicleTypes.first;
                            }
                          }

                          return RescueVehicleSelector(
                            selectedVehicleType: selectedVehicleType,
                            vehicles: vehicles,
                            onTap: () => VehicleSelectorBottomSheet.show(
                              context,
                              selectedVehicleType: selectedVehicleType,
                              registeredVehicles: vehicles,
                              onVehicleSelected: (type) {
                                setState(() => selectedVehicleType = type);
                              },
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
                      RescueIssueSelector(
                        allIssues: issues,
                        selectedIssues: selectedIssues,
                        onIssueToggle: (issue) {
                          setState(() {
                            if (selectedIssues.contains(issue)) {
                              selectedIssues.remove(issue);
                            } else {
                              selectedIssues.add(issue);
                            }
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // Location Section
                      RescueLocationPicker(
                        currentAddress: currentAddress,
                        isLoading: isLoadingLocation,
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
                      ),

                      const SizedBox(height: 24),

                      // Photo Section
                      RescueImagePicker(
                        selectedImages: selectedImages,
                        onPickImage: _pickImage,
                        onRemoveImage: (index) {
                          if (mounted) {
                            setState(() => selectedImages.removeAt(index));
                          }
                        },
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
