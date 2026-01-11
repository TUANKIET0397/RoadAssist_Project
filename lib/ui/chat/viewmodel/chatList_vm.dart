import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:road_assist/data/models/chat_model.dart';
import 'package:road_assist/data/models/message_model.dart';

/// Providers
final chatRepositoryProvider = Provider((ref) => ChatRepository());

final chatStreamProvider =
StreamProvider.family<List<ChatModel>, String>((ref, userId) {
  return ref.watch(chatRepositoryProvider).getChatStream(userId);
});

final messagesStreamProvider =
StreamProvider.family<List<MessageModel>, String>((ref, chatId) {
  return ref.watch(chatRepositoryProvider).getMessagesStream(chatId);
});


/// Repository
class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ChatModel>> getChatStream(String userId) {
    return _firestore
        .collection('chats')
        .where('userId', isEqualTo: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => ChatModel.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  /// Get or create chat
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
      'unreadCount': 0,
      'isFromUser': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return chatRef.id;
  }

  /// Send text message
  Future<void> sendTextMessage({
    required String chatId,
    required String senderId,
    required String senderRole,
    required String text,
  }) async {
    final now = DateTime.now();
    final chatRef = _firestore.collection('chats').doc(chatId);
    final messageRef = chatRef.collection('messages').doc();

    final message = MessageModel(
      id: messageRef.id,
      senderId: senderId,
      senderRole: senderRole,
      type: 'text',
      text: text,
      imageUrl: null,
      createdAt: now,
      readBy: [senderId],
    );

    await _firestore.runTransaction((tx) async {
      tx.set(messageRef, message.toMap());

      tx.update(chatRef, {
        'lastMessage': text,
        'lastMessageTime': Timestamp.fromDate(now),
        'isFromUser': senderRole == 'user',
        'unreadCount': FieldValue.increment(1),
      });
    });
  }


  /// Messages realtime

  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
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


  /// Mark messages as read

  Future<void> markAsRead({
    required String chatId,
    required String userId,
  }) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    final messagesRef = chatRef.collection('messages');

    final snapshot = await messagesRef
        .where('senderId', isNotEqualTo: userId)
        .get();

    final batch = _firestore.batch();
    bool needUpdate = false;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final List<dynamic> readBy = data['readBy'] ?? [];

      if (!readBy.contains(userId)) {
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([userId]),
        });
        needUpdate = true;
      }
    }

    if (needUpdate) {
      batch.update(chatRef, {'unreadCount': 0});
      await batch.commit();
    }
  }

}
