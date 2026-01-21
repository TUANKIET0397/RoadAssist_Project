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
  final String? imageUrl;
  final String? bgimgUrl;

  bool isFavorite;
  double? distance;


  GarageModel({
    required this.id,
    required this.name,
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
    this.distance,
  });

  factory GarageModel.fromMap(String id, Map<String, dynamic> data) {
    return GarageModel(
      id: id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
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
      distance: null,
    );
  }

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

  GarageModel copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    List<String>? vehicleTypes,
    List<String>? issues,
    String? openTime,
    String? closeTime,
    double? lat,
    double? lng,
    double? rating,
    bool? isActive,
    double? distance,
    String? imageUrl,
    String? bgimgUrl,
    bool? isFavorite,
    double? distanceKm,
  }) {
    return GarageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      vehicleTypes: vehicleTypes ?? this.vehicleTypes,
      issues: issues ?? this.issues,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      rating: rating ?? this.rating,
      isActive: isActive ?? this.isActive,
      distance: distance ?? this.distance,
      imageUrl: imageUrl ?? this.imageUrl,
      bgimgUrl: bgimgUrl ?? this.bgimgUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}