import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String senderRole;
  final String type;
  final String? text;
  final String? imageUrl;
  final DateTime createdAt;
  final List<String> readBy;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.type,
    this.text,
    this.imageUrl,
    required this.createdAt,
    required this.readBy,
  });

  factory MessageModel.fromMap(String id, Map<String, dynamic> data) {
    final Timestamp? ts = data['createdAt'];

    return MessageModel(
      id: id,
      senderId: data['senderId'] ?? '',
      senderRole: data['senderRole'] ?? 'user',
      type: data['type'] ?? 'text',
      text: data['text'],
      imageUrl: data['imageUrl'],
      createdAt: ts?.toDate() ?? DateTime.now(),
      readBy: List<String>.from(data['readBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderRole': senderRole,
      'type': type,
      'text': text,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'readBy': readBy,
    };
  }
}