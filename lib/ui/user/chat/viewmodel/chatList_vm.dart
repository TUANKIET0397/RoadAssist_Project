import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:road_assist/core/providers/auth_provider.dart';
import 'package:road_assist/data/models/chat_model.dart';
import 'package:road_assist/data/models/message_model.dart';

/// PROVIDERS

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref);
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
  );
});

/// REPOSITORY

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Ref _ref;

  ChatRepository(this._ref);

  Stream<List<ChatModel>> getChatListByRole({
    required String userId,
  }) {
    return _firestore
        .collection('chats')
        .where('members', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
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

  /// Get or create Chat - FIXED VERSION
  Future<String> getOrCreateChat({
    required String userId,
    required String garageId,
  }) async {
    print('🔍 Checking chat for userId: $userId, garageId: $garageId');

    final existing = await _firestore
        .collection('chats')
        .where('members', arrayContains: userId)
        .get();


    for (var doc in existing.docs) {
      final data = doc.data();
      final members = List<String>.from(data['members'] ?? []);


      if (members.length == 2 &&
          members.contains(userId) &&
          members.contains(garageId)) {
        return doc.id;
      }
    }


    final userDoc = await _firestore.collection('users').doc(userId).get();
    final garageDoc = await _firestore.collection('garages').doc(garageId).get();

    final chatRef = await _firestore.collection('chats').add({
      'members': [userId, garageId],
      'memberInfo': {
        userId: {
          'role': 'customer',
          'name': userDoc.data()?['name'] ?? 'User',
          'avatar': userDoc.data()?['image'] ?? ''
        },
        garageId: {
          'role': 'garage',
          'name': garageDoc.data()?['name'] ?? 'Garage',
          'avatar': garageDoc.data()?['image'] ?? ''
        }
      },
      'lastMessage': '',
      'lastSenderId': '',
      'updatedAt': FieldValue.serverTimestamp(),
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