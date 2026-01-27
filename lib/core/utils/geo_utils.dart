import 'dart:math';

/// Utility class cho các phép tính địa lý
class GeoUtils {
  GeoUtils._(); // Private constructor - không cho phép tạo instance

  /// Tính khoảng cách giữa 2 tọa độ (Haversine formula)
  /// Returns: khoảng cách tính bằng km
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295; // Pi / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R, R = 6371 km
  }

  /// Tính delta latitude cho bán kính (km)
  static double latDeltaForRadius(double radiusKm) {
    return radiusKm / 111.0;
  }

  /// Tính delta longitude cho bán kính (km) - approximation
  static double lngDeltaForRadius(double radiusKm) {
    return radiusKm / (111.0 * 0.7);
  }

  /// Kiểm tra xem một điểm có nằm trong bán kính không
  static bool isWithinRadius({
    required double centerLat,
    required double centerLng,
    required double pointLat,
    required double pointLng,
    required double radiusKm,
  }) {
    final distance = calculateDistance(centerLat, centerLng, pointLat, pointLng);
    return distance <= radiusKm;
  }
}
