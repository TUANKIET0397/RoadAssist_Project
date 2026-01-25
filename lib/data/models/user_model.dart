import 'package:road_assist/ui/user/account/model/vehicle_model.dart';

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String? email;
  final List<Vehicle> vehicles;
  final bool isActive;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
    required this.vehicles,
    required this.isActive,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      email: json['email'] is String && (json['email'] as String).isNotEmpty
          ? json['email']
          : null,
      vehicles: (json['vehicles'] as List<dynamic>? ?? []).map((e) {
        // 🔵 DATA CŨ: String
        if (e is String) {
          return Vehicle(type: e);
        }

        // 🟢 DATA MỚI: Map
        if (e is Map<String, dynamic>) {
          return Vehicle.fromMap(e);
        }

        throw Exception('Invalid vehicle data: $e');
      }).toList(),
      isActive: json['isActive'] ?? false,
      role: json['role'] ?? '',
    );
  }

  /// ====== UI helpers (KHÔNG ảnh hưởng Firestore) ======
  String get firstName {
    if (name.trim().isEmpty) return '';
    return name.split(' ').first;
  }

  String get lastName {
    if (name.trim().isEmpty) return '';
    final parts = name.split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  String get displayName => name;
}

// class UserModel {
//   final String? avatar;
//   final String name;
//   final String phone;
//   final String? email;

//   const UserModel({
//     required this.avatar,
//     required this.name,
//     required this.phone,
//     this.email,
//   });

//   factory UserModel.mock() {
//     return const UserModel(
//       avatar: null,
//       name: 'Minh Thuận',
//       phone: ' 337 760 280',
//       email: null,
//     );
//   }
// }
