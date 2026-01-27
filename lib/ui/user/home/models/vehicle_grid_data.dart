class VehicleGridData {
  final String title;
  final String subtitle1;
  final String subtitle2;
  final String image;
  final bool isFavorite;
  final String? vehicleType; // Loại xe để dùng khi navigate

  VehicleGridData({
    required this.title,
    required this.subtitle1,
    required this.subtitle2,
    required this.image,
    this.isFavorite = false,
    this.vehicleType,
  });

  VehicleGridData copyWith({bool? isFavorite}) {
    return VehicleGridData(
      title: title,
      subtitle1: subtitle1,
      subtitle2: subtitle2,
      image: image,
      isFavorite: isFavorite ?? this.isFavorite,
      vehicleType: vehicleType,
    );
  }
}
