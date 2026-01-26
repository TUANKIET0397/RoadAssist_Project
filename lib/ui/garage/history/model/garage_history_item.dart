enum GarageHistoryStatus { completed, cancelled }

class GarageHistoryItem {
  final String? rescueRequestId;
  final String vehicleType;
  final String vehicleName;
  final String vehicleModel;
  final String image;
  final GarageHistoryStatus status;
  final String issue;
  final String address;
  final String completedTime;
  final String? userName;
  final String? userPhone;
  final double? latitude;
  final double? longitude;

  GarageHistoryItem({
    this.rescueRequestId,
    required this.vehicleType,
    required this.vehicleName,
    required this.vehicleModel,
    required this.image,
    required this.status,
    required this.issue,
    required this.address,
    required this.completedTime,
    this.userName,
    this.userPhone,
    this.latitude,
    this.longitude,
  });
}
