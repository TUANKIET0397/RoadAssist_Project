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
  /// Send call history message to chat
  /// Determines customer and garage from userIds and sends message
  Future<void> sendCallHistoryMessage({
    required String callerId,
    required String receiverId,
    required int durationSeconds,
  }) async {
    try {
      // Determine which is customer and which is garage
      // Check both users and garages collections
      final callerUserDoc = await _firestore.collection('users').doc(callerId).get();
      final callerGarageDoc = await _firestore.collection('garages').doc(callerId).get();
      final receiverUserDoc = await _firestore.collection('users').doc(receiverId).get();
      final receiverGarageDoc = await _firestore.collection('garages').doc(receiverId).get();

      String customerId;
      String garageId;

      if (callerUserDoc.exists) {
        // Caller is customer
        customerId = callerId;
        garageId = receiverId;
      } else if (callerGarageDoc.exists) {
        // Caller is garage
        customerId = receiverId;
        garageId = callerId;
      } else if (receiverUserDoc.exists) {
        // Receiver is customer
        customerId = receiverId;
        garageId = callerId;
      } else {
        // Receiver is garage
        customerId = callerId;
        garageId = receiverId;
      }

      // Get or create chat
      final chatId = await getOrCreateChat(
        userId: customerId,
        garageId: garageId,
      );

      // Format duration
      final minutes = durationSeconds ~/ 60;
      final seconds = durationSeconds % 60;
      final durationText = minutes > 0
          ? '$minutes phút ${seconds}s'
          : '$seconds giây';

      final callHistoryText = '📞 Cuộc gọi đã kết thúc. Thời lượng: $durationText';

      final now = DateTime.now();
      final chatRef = _firestore.collection('chats').doc(chatId);
      final messageRef = chatRef.collection('messages').doc();

      // Determine sender (use caller as sender)
      final senderId = callerId;
      final senderRole = callerId == customerId ? 'customer' : 'garage';
      final receiverRole = senderRole == 'customer' ? 'garage' : 'customer';

      final message = MessageModel(
        id: messageRef.id,
        senderId: senderId,
        senderRole: senderRole,
        type: 'text',
        text: callHistoryText,
        imageUrl: null,
        createdAt: now,
        readBy: [senderId],
      );

      await _firestore.runTransaction((tx) async {
        tx.set(messageRef, message.toMap());

        tx.update(chatRef, {
          'lastMessage': callHistoryText,
          'lastMessageTime': Timestamp.fromDate(now),
          'lastSenderId': senderId,
          'lastSenderRole': senderRole,
          'updatedAt': FieldValue.serverTimestamp(),
          'unread.$receiverRole': FieldValue.increment(1),
        });
      });
    } catch (e) {
      print('❌ Error sending call history message: $e');
      // Don't throw - this is a non-critical operation
    }
  }
}