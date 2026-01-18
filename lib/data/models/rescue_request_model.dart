import 'package:cloud_firestore/cloud_firestore.dart';

class RescueRequestModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String vehicleType;
  final String vehicleModel;
  final List<String> issues;
  final String location;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final String status; // pending, accepted, completed, cancelled
  final List<String> statusUpdates = [
    'Garage đã nhận yêu cầu',
    'Garage đang điều phối kỹ thuật',
    'Garage sẽ liên hệ trong ít phút',
  ];
  final DateTime createdAt;
  final String? garageId;
  final String? garageName;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  RescueRequestModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.vehicleType,
    required this.vehicleModel,
    required this.issues,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    required this.status,
    required this.createdAt,
    this.garageId,
    this.garageName,
    this.acceptedAt,
    this.completedAt, required List<String> statusUpdates,
  });

  factory RescueRequestModel.fromMap(String id, Map<String, dynamic> data) {
    return RescueRequestModel(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhone: data['userPhone'] ?? '',
      vehicleType: data['vehicleType'] ?? '',
      vehicleModel: data['vehicleModel'] ?? '',
      issues: List<String>.from(data['issues'] ?? []),
      location: data['location'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'],
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      garageId: data['garageId'],
      garageName: data['garageName'],
      acceptedAt: data['acceptedAt'] != null
          ? (data['acceptedAt'] as Timestamp).toDate()
          : null,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null, statusUpdates: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'vehicleType': vehicleType,
      'vehicleModel': vehicleModel,
      'issues': issues,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'garageId': garageId,
      'garageName': garageName,
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'completedAt':
      completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  // Get status color
  String getStatusText() {
    switch (status) {
      case 'pending':
        return 'Đang chờ';
      case 'accepted':
        return 'Đã nhận';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      case 'timed_out':
        return 'Hết thời gian';
      default:
        return 'Không xác định';
    }
  }

  // Get time ago
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}