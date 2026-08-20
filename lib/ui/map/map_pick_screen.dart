import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:road_assist/core/services/gps/location_geolocator.dart';
import 'package:road_assist/ui/map/location_pick_result.dart';

class MapPickScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapPickScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<MapPickScreen> createState() => _MapPickScreenState();
}

class _MapPickScreenState extends State<MapPickScreen> {
  LatLng? selectedLatLng;
  String address = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (widget.initialLat != null && widget.initialLng != null) {
      selectedLatLng = LatLng(widget.initialLat!, widget.initialLng!);
    } else {
      final pos = await LocationService.getCurrentPosition();
      selectedLatLng = LatLng(pos.latitude, pos.longitude);
    }
    await _updateAddress();
    setState(() {});
  }

  Future<void> _updateAddress() async {
    if (selectedLatLng == null) return;
    try {
      address = await LocationService.getAddressFromLatLng(
        selectedLatLng!.latitude,
        selectedLatLng!.longitude,
      );
    } catch (_) {
      address = '${selectedLatLng!.latitude}, ${selectedLatLng!.longitude}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selectedLatLng == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn vị trí'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                LocationPickResult(
                  latitude: selectedLatLng!.latitude,
                  longitude: selectedLatLng!.longitude,
                  address: address,
                ),
              );
            },
            child: const Text('Xong', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: selectedLatLng!,
          initialZoom: 16,
          onTap: (_, point) async {
            selectedLatLng = point;
            await _updateAddress();
            setState(() {});
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.roadAssist',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: selectedLatLng!,
                width: 50,
                height: 50,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
