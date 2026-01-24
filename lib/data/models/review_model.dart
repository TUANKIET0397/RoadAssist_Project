import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String userId;
  final String userName;
  final String? userAvatar;
  final String comment;
  final double rating;
  final DateTime createdAt;

  ReviewModel({
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userAvatar: map['userAvatar'],
      comment: map['comment'] ?? '',
      rating: (map['rating'] as num).toDouble(),

      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
