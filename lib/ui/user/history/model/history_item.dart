enum Status { completed, cancelled }

class HistoryItem {
  final String? rescueRequestId;
  final String vehicleType;
  final String vehicleName;
  final String vehicleModel;
  final String image;
  final Status status;
  final String issue;
  final String address;
  final String completedTime;
  final String? garageName;
  final String? userPhone;
  final double? latitude;
  final double? longitude;

  HistoryItem({
    this.rescueRequestId,
    required this.vehicleType,
    required this.vehicleName,
    required this.vehicleModel,
    required this.image,
    required this.status,
    required this.issue,
    required this.address,
    required this.completedTime,
    this.garageName,
    this.userPhone,
    this.latitude,
    this.longitude,
  });
}
