import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/services/garage_scanner_service.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_viewmodel.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_navigation_provider.dart';
import 'package:road_assist/ui/user/rescue/widgets/rescue_location_card.dart';
import 'package:road_assist/ui/user/rescue/widgets/rescue_status_checklist.dart';
import 'package:road_assist/ui/user/rescue/widgets/rescue_vehiclecard.dart';
import 'package:road_assist/ui/user/rescue/widgets/rescue_cancel_button.dart';
import 'package:road_assist/ui/user/rescue/widgets/radar_scanner.dart';

class UserRescueWaitingScreen extends ConsumerStatefulWidget {
  final String rescueRequestId;

  const UserRescueWaitingScreen({
    super.key,
    required this.rescueRequestId,
  });

  @override
  ConsumerState<UserRescueWaitingScreen> createState() =>
      _UserRescueWaitingScreenState();
}

class _UserRescueWaitingScreenState
    extends ConsumerState<UserRescueWaitingScreen> {
  GarageScannerService? _garageScannerService;
  StreamSubscription? _scanSubscription;
  
  // UI state
  ScanPhase _currentPhase = ScanPhase.phase1;
  int _phase1GarageCount = 0;
  int _phase2GarageCount = 0;
  Timer? _uiUpdateTimer;
  String? _acceptedGarageName;

  bool _hasStartedScanning = false;
  bool _needsToListenForData = false;

  @override
  void initState() {
    super.initState();
    _startUIUpdateTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Start scanning only once
    if (!_hasStartedScanning) {
      debugPrint('STARTING GARAGE SCANNING INITIALIZATION');
      
      // Use addPostFrameCallback to ensure widget is fully built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startGarageScanning();
      });
    }
  }

  void _startUIUpdateTimer() {
    _uiUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
      });
    });
  }

  Future<void> _startGarageScanning() async {
    try {
      final rescueRequestAsync = ref.read(currentRescueRequestProvider(widget.rescueRequestId));
      
      // Check if we already have data available
      if (rescueRequestAsync.hasValue && rescueRequestAsync.value != null) {
        final rescueRequest = rescueRequestAsync.value!;
        _hasStartedScanning = true;
        _executeGarageScanning(rescueRequest);
        return;
      }
      
      // If no immediate data, set flag for build method to handle listening
      setState(() {
        _needsToListenForData = true;
      });
      
    } catch (e) {
      if (kDebugMode) print('[WaitingScreen] Lỗi khởi tạo garage scanner: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khởi tạo: $e')),
        );
      }
    }
  }

  void _executeGarageScanning(RescueRequestModel rescueRequest) {
    if (!mounted) return;

    // Execute scanning in next frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      
      _garageScannerService = GarageScannerService();
      
      final scanStream = _garageScannerService!.scanForGarages(
        rescueRequestId: widget.rescueRequestId,
        userLat: rescueRequest.latitude,
        userLng: rescueRequest.longitude,
      );

      _scanSubscription = scanStream.listen(
        (result) {
          if (kDebugMode) {
            print('[WaitingScreen] Scan result: phase=${result.phase}, garages=${result.garages.length}');
          }
          
          if (!mounted) return;
          
          // Lưu garage vào provider thay vì local state
          final navNotifier = ref.read(rescueNavigationProvider.notifier);
          navNotifier.addScannedGarages(result.garages);
          
          setState(() {
            _currentPhase = result.phase;
            
            switch (result.phase) {
              case ScanPhase.phase1:
                _phase1GarageCount = result.garages.length;
                break;
              case ScanPhase.phase2:
                _phase2GarageCount = result.garages.length;
                break;
              case ScanPhase.completed:
                _acceptedGarageName = result.acceptedGarageName;
                
                // Garage đã nhận, chuyển success
                if (result.hasAcceptance) {
                  navNotifier.navigateToSuccess(
                    requestId: widget.rescueRequestId,
                    garageId: result.acceptedGarageId,
                    garageName: result.acceptedGarageName,
                  );
                }
                break;
              case ScanPhase.failed:
                // Truyền danh sách garage đã quét được (dù không ai nhận)
                final scannedGarages = ref.read(rescueNavigationProvider).scannedGarages;
                navNotifier.navigateToNoGarage(
                  requestId: widget.rescueRequestId,
                  garages: scannedGarages,
                );
                break;
            }
          });
        },
        onError: (error) {
          if (kDebugMode) print('[WaitingScreen] Lỗi garage scanner: $error');
        },
      );
    });
  }
  Future<void> _cancelRequest() async {
    final repo = ref.read(rescueRequestRepoProvider);
    // Xóa hoàn toàn request khỏi database khi ở waiting screen
    final success = await repo.deleteRescueRequest(widget.rescueRequestId);

    if (success && mounted) {
      _cleanup();
      ref.read(rescueNavigationProvider.notifier).backToRequest();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã hủy yêu cầu cứu hộ')),
      );
    }
  }

  void _cleanup() {
    _scanSubscription?.cancel();
    _garageScannerService?.dispose();
    _uiUpdateTimer?.cancel();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  String _getPhaseDescription() {
    switch (_currentPhase) {
      case ScanPhase.phase1:
        return 'Đang tìm kiếm garage gần nhất';
      case ScanPhase.phase2:
        return 'Mở rộng tìm kiếm garage';
      case ScanPhase.completed:
        return 'Đã tìm thấy garage!';
      case ScanPhase.failed:
        return 'Không tìm thấy garage';
    }
  }

  List<String> _getStatusItems() {
    final items = <String>[];
    
    if (_currentPhase == ScanPhase.phase1) {
      items.addAll([
        'Yêu cầu cứu hộ đã gửi ',
        'Đang quét garage gần nhất',
        if (_phase1GarageCount > 0) 'Tìm thấy $_phase1GarageCount garage gần bạn',
        'Chờ garage phản hồi...',
      ]);
    } else if (_currentPhase == ScanPhase.phase2) {
      items.addAll([
        'Mở rộng tìm kiếm garage',
        if (_phase2GarageCount > 0) 'Tìm thấy $_phase2GarageCount garage trong vùng mở rộng',
        'Chờ garage phản hồi...',
      ]);
    } else if (_currentPhase == ScanPhase.completed) {
      items.addAll([
        '${_acceptedGarageName ?? "Garage"} đã chấp nhận yêu cầu',
        'Garage đang chuẩn bị...',
        'Bạn sẽ nhận thông báo sớm',
      ]);
    }
    
    return items;
  }


  @override
  Widget build(BuildContext context) {
    final rescueRequest = ref.watch(
      currentRescueRequestProvider(widget.rescueRequestId),
    );

    // Handle listening for data when immediate data wasn't available
    // ref.listen must be called outside of conditions to work properly
    ref.listen(currentRescueRequestProvider(widget.rescueRequestId), (previous, next) {
      debugPrint('Build listener: Provider state changed: ${previous?.runtimeType} -> ${next.runtimeType}');
      
      // Only process if we're waiting for data and haven't started scanning yet
      if (_needsToListenForData && !_hasStartedScanning && next.hasValue && next.value != null) {
        debugPrint('DATA RECEIVED VIA BUILD LISTENER - STARTING GARAGE SCANNING');
        final rescueRequest = next.value!;
        debugPrint('Rescue request data: $rescueRequest');
        
        setState(() {
          _needsToListenForData = false;  // Stop waiting for data
          _hasStartedScanning = true;     // Mark as started
        });
        
        _executeGarageScanning(rescueRequest);
      } else {
        debugPrint('Build listener conditions:');
        debugPrint('   _needsToListenForData: $_needsToListenForData');
        debugPrint('   !_hasStartedScanning: ${!_hasStartedScanning}');
        debugPrint('   hasValue: ${next.hasValue}');
        debugPrint('   value != null: ${next.value != null}');
        
        if (_needsToListenForData && _hasStartedScanning) {
          debugPrint('Already started scanning - skipping');
        } else if (!_needsToListenForData) {
          debugPrint('Not waiting for data - skipping');
        } else if (!next.hasValue || next.value == null) {
          debugPrint('No valid data yet - waiting...');
        }
        
        if (next.hasError) {
          debugPrint('ERROR RECEIVED VIA BUILD LISTENER ===');
          debugPrint('Error: ${next.error}');
          
          setState(() {
            _needsToListenForData = false;
          });
        }
      }
    });

    return PopScope(
      onPopInvokedWithResult: (didPop, result) => false,
      child: Scaffold(
        body: rescueRequest.when(
          data: (request) {
            if (request == null) {
              return const Center(child: Text('Không tìm thấy yêu cầu'));
            }

            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1e3a8a), Color(0xFF0f172a)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 5),

                      // Radar Scanner với phase indicator
                      RadarScanner(
                        phase: _currentPhase,
                        phase1Count: _phase1GarageCount,
                        phase2Count: _phase2GarageCount,
                      ),

                      const SizedBox(height: 5),

                      Text(
                        _getPhaseDescription(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      if (_currentPhase == ScanPhase.phase1)
                        Text(
                          'Vui lòng chờ trong giây lát....',
                          style: TextStyle(
                            color: Colors.blue.shade200,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        )
                      else if (_currentPhase == ScanPhase.phase2)
                        Text(
                          'Vui lòng chờ trong giây lát....',
                          style: TextStyle(
                            color: Colors.orange.shade200,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),

                      const SizedBox(height: 32),

                      // Vehicle info card
                      RescueVehicleCard(request: request),
                      
                      const SizedBox(height: 16),

                      // Dynamic status checklist
                      RescueStatusChecklist(
                        items: _getStatusItems(),
                      ),

                      const SizedBox(height: 16),

                      // Location info
                      RescueLocationCard(
                        location: request.location,
                        userPhone: request.userPhone,
                      ),
                      const SizedBox(height: 16),

                      // Cancel button
                      RescueCancelButton(
                        enabled: true,
                        onConfirmCancel: _cancelRequest,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Vui lòng đảm bảo rằng bạn vẫn ở vị trí như ở trên!',
                        style: TextStyle(
                          color: Colors.blue.shade300,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Lỗi: $error')),
        ),
      ),
    );
  }
     
}
