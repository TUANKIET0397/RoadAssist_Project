import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerScreen extends StatefulWidget {
  final double lat;
  final double lng;

  const MapPickerScreen({
    super.key,
    required this.lat,
    required this.lng,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng selectedLatLng;

  @override
  void initState() {
    super.initState();
    selectedLatLng = LatLng(widget.lat, widget.lng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn vị trí'),
        backgroundColor: const Color(0xFF001029),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: selectedLatLng,
          zoom: 16,
        ),
        onTap: (latLng) {
          setState(() {
            selectedLatLng = latLng;
          });
        },
        markers: {
          Marker(
            markerId: const MarkerId('picked'),
            position: selectedLatLng,
          ),
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.check),
        onPressed: () {
          Navigator.pop(context, selectedLatLng);
        },
      ),
    );
  }
}
