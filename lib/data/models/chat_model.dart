import 'package:cloud_firestore/cloud_firestore.dart';


class ChatModel {
  final String id;
  final String userId;
  final String garageId;
  final String garageName;
  final String garageImage;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastSenderId;
  final Map<String, int> unread;
  final DateTime createdAt;

  ChatModel({
    required this.id,
    required this.userId,
    required this.garageId,
    required this.garageName,
    required this.garageImage,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastSenderId,
    required this.unread,
    required this.createdAt,
  });

  factory ChatModel.fromMap(String id, Map<String, dynamic> data) {
    final Timestamp? lastTs = data['lastMessageTime'];
    final Timestamp? createdTs = data['createdAt'];

    return ChatModel(
      id: id,
      userId: data['userId'] ?? '',
      garageId: data['garageId'] ?? '',
      garageName: data['garageName'] ?? '',
      garageImage: data['garageImage'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: lastTs?.toDate() ?? DateTime.now(),
      lastSenderId: data['lastSenderId'] ?? '',
      unread: Map<String, int>.from(data['unread'] ?? {}),
      createdAt: createdTs?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'garageId': garageId,
      'garageName': garageName,
      'garageImage': garageImage,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastSenderId': lastSenderId,
      'unread': unread,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Tính thời gian hiển thị
  String getTimeAgo() {
    final difference = DateTime.now().difference(lastMessageTime);

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