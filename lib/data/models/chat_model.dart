import 'package:cloud_firestore/cloud_firestore.dart';

class Participant {
  final String uid;
  final String name;
  final String avatar;
  final String role;

  Participant({
    required this.uid,
    required this.name,
    required this.avatar,
    required this.role,
  });

  factory Participant.fromMap(String uid, Map<String, dynamic> map) {
    return Participant(
      uid: uid,
      name: map['name'] ?? '',
      avatar: map['avatar'] ?? '',
      role: map['role'] ?? '',
    );
  }
}

class ChatModel {
  final String chatId;
  final List<String> members;
  final Map<String, Participant> memberInfo;
  final String lastMessage;
  final String lastSenderId;
  final Timestamp updatedAt;
  final Timestamp createdAt;

  ChatModel({
    required this.chatId,
    required this.members,
    required this.memberInfo,
    required this.lastMessage,
    required this.lastSenderId,
    required this.updatedAt,
    required this.createdAt,
  });

  factory ChatModel.fromMap(String id, Map<String, dynamic> map) {
    return ChatModel(
      chatId: id,
      members: List<String>.from(map['members'] ?? []),
      memberInfo:
          (map['memberInfo'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, Participant.fromMap(key, value)),
          ) ??
          {},
      lastMessage: map['lastMessage'] ?? '',
      lastSenderId: map['lastSenderId'] ?? '',
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  Participant? getOtherParticipant(String currentUserId) {
    final otherMemberId = members.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    if (otherMemberId.isEmpty) {
      return null;
    }
    return memberInfo[otherMemberId];
  }
}
