import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String garageId;
  final String garageName;
  final String garageImage;
  final String userId;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isFromUser;

  ChatModel({
    required this.id,
    required this.garageId,
    required this.garageName,
    required this.garageImage,
    required this.userId,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isFromUser,
  });

  factory ChatModel.fromMap(String id, Map<String, dynamic> data) {
    return ChatModel(
      id: id,
      garageId: data['garageId'] ?? '',
      garageName: data['garageName'] ?? '',
      garageImage: data['garageImage'] ?? '',
      userId: data['userId'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      unreadCount: data['unreadCount'] ?? 0,
      isFromUser: data['isFromUser'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'garageId': garageId,
      'garageName': garageName,
      'garageImage': garageImage,
      'userId': userId,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'unreadCount': unreadCount,
      'isFromUser': isFromUser,
    };
  }

  // Tính thời gian hiển thị
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(lastMessageTime);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} d ago';
    } else {
      return '${lastMessageTime.day}/${lastMessageTime.month}/${lastMessageTime.year}';
    }
  }
}