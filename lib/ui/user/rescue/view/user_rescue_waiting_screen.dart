import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/services/garage_scanner_service.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';
import 'package:road_assist/data/models/garage_model.dart';
import 'package:road_assist/ui/user/rescue/viewmodel/rescue_viewmodel.dart';
import 'package:road_assist/ui/user/rescue/widgets/rescue_location_card.dart';
import 'package:road_assist/ui/user/rescue/widgets/rescue_status_checklist.dart';
import 'package:road_assist/ui/user/rescue/widgets/rescue_vehiclecard.dart';
import 'package:road_assist/ui/user/rescue/widgets/rescue_cancel_button.dart';

class UserRescueWaitingScreen extends ConsumerStatefulWidget {
  final String rescueRequestId;
  final Function(String requestId, String? garageId, String? name) onNavigateToSuccess;
  final Function(String requestId, [List<GarageModel>? garages]) onNavigateToNoGarage;
  final Function() onBack;

  const UserRescueWaitingScreen({
    super.key,
    required this.rescueRequestId,
    required this.onNavigateToSuccess,
    required this.onNavigateToNoGarage,
    required this.onBack,
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
  int _elapsedSeconds = 0;
  Timer? _uiUpdateTimer;
  bool _scanCompleted = false;
  List<GarageModel> _allScannedGarages = [];  // Lưu tất cả garage đã quét

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
      debugPrint('🔧 === STARTING GARAGE SCANNING INITIALIZATION ===');
      
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
        _elapsedSeconds++;
      });
    });
  }

  Future<void> _startGarageScanning() async {
    try {
      debugPrint('🚀 Bắt đầu _startGarageScanning...');
      debugPrint('🆔 Rescue Request ID: ${widget.rescueRequestId}');
      
      // Use ref.read() for one-time access
      final rescueRequestAsync = ref.read(currentRescueRequestProvider(widget.rescueRequestId));
      
      debugPrint('📋 Đã lấy rescueRequestAsync provider với read...');
      debugPrint('🔍 Provider state: ${rescueRequestAsync.runtimeType}');
      debugPrint('🔍 Provider hasValue: ${rescueRequestAsync.hasValue}');
      debugPrint('🔍 Provider isLoading: ${rescueRequestAsync.isLoading}');
      debugPrint('🔍 Provider hasError: ${rescueRequestAsync.hasError}');
      
      // Check if we already have data available
      if (rescueRequestAsync.hasValue && rescueRequestAsync.value != null) {
        debugPrint('✅ === IMMEDIATE DATA AVAILABLE ===');
        final rescueRequest = rescueRequestAsync.value!;
        debugPrint('📋 Rescue request data: $rescueRequest');
        
        // Mark as started when we have immediate data
        _hasStartedScanning = true;
        
        _executeGarageScanning(rescueRequest);
        return;
      }
      
      // If no immediate data, set flag for build method to handle listening
      debugPrint('⏳ === NO IMMEDIATE DATA - SETTING BUILD LISTENER FLAG ===');
      setState(() {
        _needsToListenForData = true;
      });
      
    } catch (e) {
      debugPrint('❌ Lỗi khởi tạo garage scanner: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khởi tạo: $e')),
        );
      }
    }
  }

  void _executeGarageScanning(RescueRequestModel rescueRequest) {
    if (!mounted) {
      debugPrint('❌ Widget unmounted - aborting scanning');
      return;
    }
    
    debugPrint('🎯 === EXECUTING GARAGE SCANNING ===');
    debugPrint('📍 User position: lat=${rescueRequest.latitude}, lng=${rescueRequest.longitude}');

    // Execute scanning in next frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      
      debugPrint('🔍 === PHASE 1 START ===');
      
      _garageScannerService = GarageScannerService();
      
      final scanStream = _garageScannerService!.scanForGarages(
        rescueRequestId: widget.rescueRequestId,
        userLat: rescueRequest.latitude,
        userLng: rescueRequest.longitude,
      );

      debugPrint('🔄 Đang subscribe đến scan stream...');

      _scanSubscription = scanStream.listen(
        (result) {
          debugPrint('📨 Nhận scan result: phase=${result.phase}, garages=${result.garages.length}');
          
          if (!mounted) return;
          
          setState(() {
            _currentPhase = result.phase;
            
            // Lưu garage từ mỗi phase, tránh duplicate bằng cách check ID
            for (var garage in result.garages) {
              if (!_allScannedGarages.any((existing) => existing.id == garage.id)) {
                _allScannedGarages.add(garage);
              }
            }
            
            switch (result.phase) {
              case ScanPhase.phase1:
                _phase1GarageCount = result.garages.length;
                debugPrint('✅ Phase 1: ${_phase1GarageCount} garage(s)');
                break;
              case ScanPhase.phase2:
                _phase2GarageCount = result.garages.length;
                debugPrint('✅ Phase 2: ${_phase2GarageCount} garage(s)');
                break;
              case ScanPhase.completed:
                _scanCompleted = true;
                debugPrint('✅ Scan completed - garage accepted!');
                // Garage đã nhận, chuyển success
                if (result.hasAcceptance) {
                  widget.onNavigateToSuccess(
                    widget.rescueRequestId,
                    result.acceptedGarageId,
                    result.acceptedGarageName,
                  );
                }
                break;
              case ScanPhase.failed:
                _scanCompleted = true;
                debugPrint('❌ Scan failed - no garage found/accepted');
                // Truyền danh sách garage đã quét được (dù không ai nhận)
                widget.onNavigateToNoGarage(widget.rescueRequestId, _allScannedGarages);
                break;
            }
          });
        },
        onError: (error) {
          debugPrint('❌ Lỗi garage scanner: $error');
          // Don't use ScaffoldMessenger here since it's called from didChangeDependencies
          // The error will be handled in the UI through state changes
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
      widget.onBack();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã hủy yêu cầu cứu hộ')));
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
        return 'Đang quét garage gần (5km)...';
      case ScanPhase.phase2:
        return 'Mở rộng tìm kiếm (10km)...';
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
        'Yêu cầu cứu hộ đã gửi ✅',
        'Đang quét garage gần (5km)...',
        if (_phase1GarageCount > 0) 'Tìm thấy $_phase1GarageCount garage gần bạn',
        'Chờ garage phản hồi...',
      ]);
    } else if (_currentPhase == ScanPhase.phase2) {
      items.addAll([
        'Đợt 1 hoàn thành ✅',
        'Mở rộng tìm kiếm (10km)...',
        if (_phase2GarageCount > 0) 'Tìm thấy $_phase2GarageCount garage trong vùng mở rộng',
        'Chờ garage phản hồi...',
      ]);
    } else if (_currentPhase == ScanPhase.completed) {
      items.addAll([
        'Yêu cầu đã được chấp nhận ✅',
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
      debugPrint('🔔 Build listener: Provider state changed: ${previous?.runtimeType} -> ${next.runtimeType}');
      
      // Only process if we're waiting for data and haven't started scanning yet
      if (_needsToListenForData && !_hasStartedScanning && next.hasValue && next.value != null) {
        debugPrint('✅ === DATA RECEIVED VIA BUILD LISTENER - STARTING GARAGE SCANNING ===');
        final rescueRequest = next.value!;
        debugPrint('📋 Rescue request data: $rescueRequest');
        
        setState(() {
          _needsToListenForData = false;  // Stop waiting for data
          _hasStartedScanning = true;     // Mark as started
        });
        
        _executeGarageScanning(rescueRequest);
      } else {
        debugPrint('🔍 Build listener conditions:');
        debugPrint('   _needsToListenForData: $_needsToListenForData');
        debugPrint('   !_hasStartedScanning: ${!_hasStartedScanning}');
        debugPrint('   hasValue: ${next.hasValue}');
        debugPrint('   value != null: ${next.value != null}');
        
        if (_needsToListenForData && _hasStartedScanning) {
          debugPrint('⚠️  Already started scanning - skipping');
        } else if (!_needsToListenForData) {
          debugPrint('⚠️  Not waiting for data - skipping');
        } else if (!next.hasValue || next.value == null) {
          debugPrint('⚠️  No valid data yet - waiting...');
        }
        
        if (next.hasError) {
          debugPrint('❌ === ERROR RECEIVED VIA BUILD LISTENER ===');
          debugPrint('❌ Error: ${next.error}');
          
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
                          'Đợt 1/2 - Bán kính 5km',
                          style: TextStyle(
                            color: Colors.blue.shade200,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        )
                      else if (_currentPhase == ScanPhase.phase2)
                        Text(
                          'Đợt 2/2 - Bán kính 10km',
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

class RadarScanner extends StatefulWidget {
  final ScanPhase phase;
  final int phase1Count;
  final int phase2Count;
  
  const RadarScanner({
    super.key,
    this.phase = ScanPhase.phase1,
    this.phase1Count = 0,
    this.phase2Count = 0,
  });

  @override
  State<RadarScanner> createState() => _RadarScannerState();
}

class _RadarScannerState extends State<RadarScanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.phase == ScanPhase.phase2 ? 3 : 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getRadarColor() {
    switch (widget.phase) {
      case ScanPhase.phase1:
        return Colors.blue;
      case ScanPhase.phase2:
        return Colors.orange;
      case ScanPhase.completed:
        return Colors.green;
      case ScanPhase.failed:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final radarColor = _getRadarColor();
    
    return SizedBox(
      width: 150,
      height: 150,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return CustomPaint(
            painter: RadarPainterV4(
              angle: _controller.value * 2 * 3.1415926,
              radarColor: radarColor,
              phase: widget.phase,
              phase1Count: widget.phase1Count,
              phase2Count: widget.phase2Count,
            ),
          );
        },
      ),
    );
  }
}

class RadarPainterV4 extends CustomPainter {
  final double angle;
  final Color radarColor;
  final ScanPhase phase;
  final int phase1Count;
  final int phase2Count;
  
  RadarPainterV4({
    required this.angle,
    required this.radarColor,
    required this.phase,
    required this.phase1Count,
    required this.phase2Count,
  });

  static final Random _rand = Random();

  // 30 điểm radar
  static final List<_Blip> blips = List.generate(30, (_) {
    final r = _rand.nextDouble() * 0.9;
    final a = _rand.nextDouble() * 2 * pi;
    return _Blip(
      Offset(cos(a) * r, sin(a) * r),
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    /// ===== Background =====
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = const Color(0xFF020617),
    );

    /// ===== Grid =====
    final gridPaint = Paint()
      ..color = radarColor.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * i / 4, gridPaint);
    }

    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, size.height),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      gridPaint,
    );

    /// ===== Radar sweep =====
    const sweepWidth = 0.35;

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: angle,
        endAngle: angle + sweepWidth,
        colors: [
          radarColor.withOpacity(0.0),
          radarColor.withOpacity(0.7),
          radarColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      angle,
      sweepWidth,
      true,
      sweepPaint,
    );

    /// ===== Phase indicators =====
    if (phase1Count > 0) {
      _drawPhaseIndicator(canvas, center, radius * 0.5, phase1Count, Colors.blue);
    }
    if (phase2Count > 0 && phase != ScanPhase.phase1) {
      _drawPhaseIndicator(canvas, center, radius * 0.75, phase2Count, Colors.orange);
    }

    /// ===== Blips =====
    for (final blip in blips) {
      final pos = Offset(
        center.dx + blip.offset.dx * radius,
        center.dy + blip.offset.dy * radius,
      );

      final blipAngle = atan2(pos.dy - center.dy, pos.dx - center.dx);
      final diff = _angleDiff(blipAngle, angle);

      if (diff < 0.15) {
        blip.intensity = 1.0; // quét trúng
      } else {
        blip.intensity *= 0.94; // fade out
      }

      if (blip.intensity > 0.05) {
        canvas.drawCircle(
          pos,
          3 + blip.intensity * 2,
          Paint()
            ..color = radarColor.withOpacity(blip.intensity),
        );
      }
    }

    /// ===== Outer ring =====
    canvas.drawCircle(
      center,
      radius - 1.5,
      Paint()
        ..color = radarColor.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    /// ===== Center dot =====
    canvas.drawCircle(
      center,
      5,
      Paint()..color = radarColor,
    );
  }

  void _drawPhaseIndicator(Canvas canvas, Offset center, double r, int count, Color color) {
    for (int i = 0; i < count && i < 8; i++) {
      final angle = (i * 2 * pi) / 8;
      final pos = Offset(
        center.dx + cos(angle) * r,
        center.dy + sin(angle) * r,
      );
      canvas.drawCircle(
        pos,
        4,
        Paint()..color = color.withOpacity(0.8),
      );
    }
  }

  double _angleDiff(double a, double b) {
    var d = (a - b).abs();
    if (d > pi) d = 2 * pi - d;
    return d;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Blip {
  final Offset offset;
  double intensity = 0;

  _Blip(this.offset);
}
