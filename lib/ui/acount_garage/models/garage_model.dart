/// Dữ liệu garage – thuần Dart
/// Không phụ thuộc Flutter / UI
class Garage {
  final String name;
  final String phone;
  final bool isOpen;
  final String openTime;
  final String closeTime;
  final List<String> supportedVehicles;

  Garage({
    required this.name,
    required this.phone,
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
    required this.supportedVehicles,
  });
}
