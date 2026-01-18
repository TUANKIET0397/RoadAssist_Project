class Vehicle {
  final String name;
  final String? description;
  final String image;

  const Vehicle({
    required this.name,
    required this.description,
    required this.image,
  });

  static List<Vehicle> mockList() {
    return const [
      Vehicle(
        name: 'Honda Vision nnnnnnnnnnnnnnnnnnn',
        description: 'Xe máy zzzzzzzzzzzzzzzzzzzzzzzzzz',
        image: 'assets/images/illustrations/vehicle1.png',
      ),
      Vehicle(
        name: 'Toyota Vios',
        description: null,
        image: 'assets/images/illustrations/vehicle2.png',
      ),
    ];
  }
}
