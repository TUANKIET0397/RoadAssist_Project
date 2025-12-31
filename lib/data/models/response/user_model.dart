class UserModel {
  final String phoneNumber;
  final String password;

  UserModel({
    required this.phoneNumber,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'phoneNumber': phoneNumber,
    'password': password,
  };
}