class UserModel {
  final String? avatar;
  final String name;
  final String phone;
  final String? email;

  const UserModel({
    required this.avatar,
    required this.name,
    required this.phone,
    this.email,
  });

  factory UserModel.mock() {
    return const UserModel(
      avatar: null,
      name: 'Minh Thuận',
      phone: '+84 337 760 280',
      email: null,
    );
  }
}
