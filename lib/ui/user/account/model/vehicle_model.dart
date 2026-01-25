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
