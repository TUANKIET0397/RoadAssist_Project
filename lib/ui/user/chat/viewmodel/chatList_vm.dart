import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:road_assist/core/auth/auth_state.dart';
import 'package:road_assist/core/providers/auth_provider.dart';
import 'package:road_assist/data/models/chat_model.dart';
import 'package:road_assist/data/models/message_model.dart';

/// PROVIDERS

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

/// Chat list (customer / garage)
final chatListProvider = StreamProvider<List<ChatModel>>((ref) {
  final authState = ref.watch(authStateProvider);

  if (!authState.isLoggedIn ||
      !authState.isInitialized ||
      authState.userId == null ||
      authState.role == null) {
    return const Stream.empty();
  }

  return ref
      .read(chatRepositoryProvider)
      .getChatListByRole(
    userId: authState.userId!,
    role: authState.role!,
  );
});



/// REPOSITORY

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;



  Stream<List<ChatModel>> getChatListByRole({
    required String userId,
    required UserRole role,
  }) {
    late Query<Map<String, dynamic>> query;

    switch (role) {
      case UserRole.customer:
        query = _firestore
            .collection('chats')
            .where('userId', isEqualTo: userId);
        break;

      case UserRole.garage:
        query = _firestore
            .collection('chats')
            .where('garageId', isEqualTo: userId);
        break;
    }

    return query
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => ChatModel.fromMap(
          doc.id,
          doc.data(),
        ),
      )
          .toList(),
    );
  }

  /// Get or create Chat

  Future<String> getOrCreateChat({
    required String userId,
    required String garageId,
    required String garageName,
    required String garageImage,
  }) async {
    final existing = await _firestore
        .collection('chats')
        .where('userId', isEqualTo: userId)
        .where('garageId', isEqualTo: garageId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return existing.docs.first.id;
    }

    final chatRef = await _firestore.collection('chats').add({
      'userId': userId,
      'garageId': garageId,
      'garageName': garageName,
      'garageImage': garageImage,
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unread': {
        userId: 0,
        garageId: 0,
      },
      'createdAt': FieldValue.serverTimestamp(),
    });

    return chatRef.id;
  }

  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => MessageModel.fromMap(
          doc.id,
          doc.data(),
        ),
      )
          .toList(),
    );
  }

  Future<void> markAsRead({
    required String chatId,
    required String readerId,
  }) async {
    final chatRef = _firestore.collection('chats').doc(chatId);

    await chatRef.update({
      'unread.$readerId': 0,
    });
  }
}
