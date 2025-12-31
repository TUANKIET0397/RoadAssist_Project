class GarageModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final List<String> vehicleTypes;
  final List<String> services;
  final String openTime;
  final String closeTime;
  final double lat;
  final double lng;
  final double? rating;
  final bool isActive;
  final String? imageUrl;
  bool isFavorite;

  GarageModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.vehicleTypes,
    required this.services,
    required this.openTime,
    required this.closeTime,
    required this.lat,
    required this.lng,
    this.rating,
    required this.isActive,
    this.imageUrl,
    this.isFavorite = false,
  });

  factory GarageModel.fromMap(String id, Map<String, dynamic> data) {
    return GarageModel(
      id: id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      vehicleTypes: List<String>.from(data['vehicleTypes'] ?? []),
      services: List<String>.from(data['services'] ?? []),
      openTime: data['openTime'] ?? '',
      closeTime: data['closeTime'] ?? '',
      lat: (data['location']?['lat'] ?? 0).toDouble(),
      lng: (data['location']?['lng'] ?? 0).toDouble(),
      rating: data['rating']?.toDouble(),
      isActive: data['isActive'] ?? false,
      imageUrl: data['imageUrl'],
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
      'services': services,
      'openTime': openTime,
      'closeTime': closeTime,
      'location': {
        'lat': lat,
        'lng': lng,
      },
      'rating': rating,
      'isActive': isActive,
      'imageUrl': imageUrl,
    };
  }
}