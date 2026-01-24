import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/garage/home/view/garage_home_screen.dart';
import 'package:road_assist/ui/garage/home/view/garage_rescue_request_detail_screen.dart';

class GarageRescueScreenWrapper extends ConsumerStatefulWidget {
  final String? initialRequestId;

  const GarageRescueScreenWrapper({super.key, this.initialRequestId});

  @override
  ConsumerState<GarageRescueScreenWrapper> createState() =>
      _GarageRescueScreenWrapperState();
}

class _GarageRescueScreenWrapperState
    extends ConsumerState<GarageRescueScreenWrapper> {
  late String currentScreen;
  late String? selectedRequestId;

  @override
  void initState() {
    super.initState();
    currentScreen = widget.initialRequestId != null
        ? 'request_detail'
        : 'requests_list';
    selectedRequestId = widget.initialRequestId;
  }

  void _selectRequest(String requestId) {
    setState(() {
      currentScreen = 'request_detail';
      selectedRequestId = requestId;
    });
  }

  void _backToList() {
    setState(() {
      currentScreen = 'requests_list';
      selectedRequestId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentScreen == 'request_detail' && selectedRequestId != null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _backToList();
        },
        child: GarageRescueRequestDetailScreen(
          rescueRequestId: selectedRequestId!,
          onBack: _backToList,
        ),
      );
    }

    return GarageHomeScreen(onSelectRequest: _selectRequest);
  }
}
