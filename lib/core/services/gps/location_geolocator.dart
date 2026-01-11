import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Xin quyền + lấy vị trí hiện tại
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Dịch vụ định vị đã bị tắt. Vui lòng bật GPS.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Quyền truy cập vị trí đã bị từ chối.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Quyền truy cập vị trí bị từ chối vĩnh viễn. Vui lòng vào cài đặt ứng dụng để cấp quyền.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Đổi lat/lng → địa chỉ
  static Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        return '${p.street}, ${p.subAdministrativeArea}, ${p.administrativeArea}';
      } else {
        throw Exception('Không tìm thấy địa chỉ cho vị trí này.');
      }
    } catch (e) {
      throw Exception('Lỗi mạng hoặc không thể lấy được địa chỉ.');
    }
  }
}
