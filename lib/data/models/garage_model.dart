class GarageModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final List<String> vehicleTypes;
  final List<String> issues;
  final String openTime;
  final String closeTime;
  final double? lat;
  final double? lng;
  final double? rating;
  final bool isActive;
  final double? distance;
  final String? imageUrl;
  final String? bgimgUrl;
  bool isFavorite;
  

  GarageModel({
    required this.id,
    required this.name,
    required this.distance,
    required this.address,
    required this.phone,
    required this.vehicleTypes,
    required this.issues,
    required this.openTime,
    required this.closeTime,
    required this.lat,
    required this.lng,
    this.rating,
    required this.isActive,
    this.imageUrl,
    this.bgimgUrl,
    this.isFavorite = false,
  });

  factory GarageModel.fromMap(String id, Map<String, dynamic> data) {
    return GarageModel(
      id: id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      distance: data['distance']?.toDouble(),
      phone: data['phone'] ?? '',
      vehicleTypes: List<String>.from(data['vehicleTypes'] ?? []),
      issues: List<String>.from(data['issues'] ?? []),
      openTime: data['openTime'] ?? '',
      closeTime: data['closeTime'] ?? '',
      lat: (data['location']?['lat'] ?? 0).toDouble(),
      lng: (data['location']?['lng'] ?? 0).toDouble(),
      rating: data['rating']?.toDouble(),
      isActive: data['isActive'] ?? false,
      imageUrl: data['imageUrl'],
      bgimgUrl: data['bgimgUrl'],
    );
  }
  // Đăng ký garage mới.
  // FirebaseFirestore.instance.collection('garages').add(myGarage.toMap());


  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'vehicleTypes': vehicleTypes,
      'issues': issues,
      'openTime': openTime,
      'closeTime': closeTime,
      'location': {
        'lat': lat,
        'lng': lng,
      },
      'rating': rating,
      'isActive': isActive,
      'imageUrl': imageUrl,
      'bgimgUrl': bgimgUrl,

    };
  }
}