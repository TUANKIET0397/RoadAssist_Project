import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:road_assist/data/models/garage_model.dart';

class LocationService {
  /// Xin quyền + lấy vị trí (GPS)
  static Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Vui lòng bật GPS để tiếp tục');
    }

    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Quyền truy cập vị trí bị từ chối');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Quyền truy cập vị trí bị từ chối vĩnh viễn. Vui lòng cấp quyền trong cài đặt');
    }

    // 3. Lấy vị trí hiện tại
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// GPS → ĐỊA CHỈ
  static Future<String> getAddressFromLatLng(
      double latitude, double longitude) async {
    try {
      final List<Placemark> placemarks =
      await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        throw Exception('Không tìm thấy địa chỉ');
      }

      final p = placemarks.first;

      final addressParts = [
        p.street,
        p.subAdministrativeArea,
        p.administrativeArea,
      ].where((e) => e != null && e!.isNotEmpty).toList();

      return addressParts.join(', ');
    } catch (e) {
      throw Exception('Không thể lấy địa chỉ từ GPS');
    }
  }

  /// ĐỊA CHỈ → GPS
  static Future<Location?> getLatLngFromAddress(
      String address) async {
    try {
      final List<Location> locations =
      await locationFromAddress(address);

      if (locations.isEmpty) return null;

      return locations.first;
    } catch (e) {
      return null;
    }
  }

  /// Tinh distance
  Future<List<GarageModel>> calculateDistanceForGarages(
      List<GarageModel> garages,
      ) async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return garages.map((garage) {
      if (garage.lat == null || garage.lng == null) {
        return garage.copyWith(distance: null);
      }

      final meters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        garage.lat!,
        garage.lng!,
      );

      return garage.copyWith(distance: meters / 1000);
    }).toList();
  }

  static double calculateDistanceKm({
    required double garageLat,
    required double garageLng,
    required double userLat,
    required double userLng,
  }) {
    final meters = Geolocator.distanceBetween(
      garageLat,
      garageLng,
      userLat,
      userLng,
    );
    return meters / 1000;
  }

}
