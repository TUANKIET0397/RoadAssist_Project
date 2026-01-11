class User {
  final String password;
  String firstName;
  String lastName;
  String phone;
  String email;
  String address;
  DateTime birthDate;
  bool isVerified;

  User({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.address,
    required this.birthDate,
    this.isVerified = false, required this.password,

  });
  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'email': email,
    'address': address,
    'birthDate': birthDate,
    'isVerified': isVerified,
    'password': password,
  };
}

