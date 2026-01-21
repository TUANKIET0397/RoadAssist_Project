enum Status { completed, failed }

class HistoryItem {
  final String vehicleType;
  final String vehicleName;
  final String vehicleModel;
  final String image;
  final Status status;
  final String issue;
  final String address;
  final String completedTime;

  HistoryItem({
    required this.vehicleType,
    required this.vehicleName,
    required this.vehicleModel,
    required this.image,
    required this.status,
    required this.issue,
    required this.address,
    required this.completedTime,
  });
}
