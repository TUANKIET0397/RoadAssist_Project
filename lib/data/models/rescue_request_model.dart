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
  final int progressStep; // 0: pending, 1: arrived, 2: repairing, 3: completed
  final DateTime createdAt;
  final String? garageId;
  final String? name;
  final String? garagePhone;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DateTime? arrivedAt;
  final DateTime? repairingStartedAt;

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
    required this.progressStep,
    required this.createdAt,
    this.garageId,
    this.name,
    this.garagePhone,
    this.acceptedAt,
    this.completedAt,
    this.cancelledAt,
    this.arrivedAt,
    this.repairingStartedAt,
  });

  factory RescueRequestModel.fromMap(String id, Map<String, dynamic> data) {

    try {
      // Parse createdAt with fallback
      DateTime createdAt;
      if (data['createdAt'] != null) {
        if (data['createdAt'] is Timestamp) {
          createdAt = (data['createdAt'] as Timestamp).toDate();
        } else {
          createdAt = DateTime.now();
        }
      } else {
        createdAt = DateTime.now();
      }

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
        progressStep: data['progressStep'] ?? 0,
        createdAt: createdAt,
        garageId: data['garageId'],
        name: data['name'],
        garagePhone: data['garagePhone'],
        acceptedAt: data['acceptedAt'] != null
            ? (data['acceptedAt'] as Timestamp).toDate()
            : null,
        completedAt: data['completedAt'] != null
            ? (data['completedAt'] as Timestamp).toDate()
            : null,
        cancelledAt: data['cancelledAt'] != null
            ? (data['cancelledAt'] as Timestamp).toDate()
            : null,
        arrivedAt: data['arrivedAt'] != null
            ? (data['arrivedAt'] as Timestamp).toDate()
            : null,
        repairingStartedAt: data['repairingStartedAt'] != null
            ? (data['repairingStartedAt'] as Timestamp).toDate()
            : null,
      );
    } catch (e) {
      print(' Error parsing RescueRequestModel from $id: $e');
      print(' Raw data: $data');
      rethrow;
    } 
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
      'progressStep': progressStep,
      'createdAt': Timestamp.fromDate(createdAt),
      'garageId': garageId,
      'name': name,
      'garagePhone': garagePhone,
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'arrivedAt': arrivedAt != null ? Timestamp.fromDate(arrivedAt!) : null,
      'repairingStartedAt': repairingStartedAt != null ? Timestamp.fromDate(repairingStartedAt!) : null,
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