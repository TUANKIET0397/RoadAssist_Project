class CompletionPayload {
  final String title;
  final String subtitle;

  final String vehicleImage;
  final String vehicleName;
  final String vehicleModel;

  final String issue;
  final String address;
  final String completedTime;

  final String garageName;
  final String garageAvatar;

  CompletionPayload({
    required this.title,
    required this.subtitle,
    required this.vehicleImage,
    required this.vehicleName,
    required this.vehicleModel,
    required this.issue,
    required this.address,
    required this.completedTime,
    required this.garageName,
    required this.garageAvatar,
  });
}
