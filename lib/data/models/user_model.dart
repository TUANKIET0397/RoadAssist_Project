class UserModel {
  final String name;
  final String phone;
  final String? email;

  const UserModel({required this.name, required this.phone, this.email});

  factory UserModel.mock() {
    return const UserModel(
      name: 'Minh Thuận',
      phone: '+84 337 760 280',
      email: null,
    );
  }
}
