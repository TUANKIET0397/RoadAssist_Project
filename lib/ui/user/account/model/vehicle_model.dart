class Vehicle {
  final String type;
  final String? description;

  const Vehicle({required this.type, this.description});

  Map<String, dynamic> toMap() {
    return {'type': type, 'description': description};
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      type: map['type'] as String,
      description: map['description'] as String?,
    );
  }

  Vehicle copyWith({String? description}) {
    return Vehicle(type: type, description: description ?? this.description);
  }
}

// class Vehicle {
//   final String name;
//   final String? description;
//   final String image;

//   const Vehicle({
//     required this.name,
//     required this.description,
//     required this.image,
//   });

//   static List<Vehicle> mockList() {
//     return const [
//       Vehicle(
//         name: 'Honda Vision nnnnnnnnnnnnnnnnnnn',
//         description: 'Xe máy zzzzzzzzzzzzzzzzzzzzzzzzzz',
//         image: 'assets/images/illustrations/vehicle.png',
//       ),
//       Vehicle(
//         name: 'Toyota Vios',
//         description: null,
//         image: 'assets/images/illustrations/vehicle.png',
//       ),
//     ];
//   }
// }
