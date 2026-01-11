import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:road_assist/data/models/response/chat_model.dart';
import 'package:road_assist/data/models/response/message_model.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepository());

final chatStreamProvider = StreamProvider.family<List<ChatModel>, String>((ref, userId) {
  return ref.watch(chatRepositoryProvider).getChatStream(userId);
});

final messagesStreamProvider = StreamProvider.family<List<MessageModel>, String>((ref, chatId) {
  return ref.watch(chatRepositoryProvider).getMessagesStream(chatId);
});

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy danh sách chat cho user
  Stream<List<ChatModel>> getChatStream(String userId) {
    return _firestore
        .collection('chats')
        .where('userId', isEqualTo: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatModel.fromMap(doc.id, doc.data()))
        .toList());
  }

  /// Lấy hoặc tạo chat mới
  Future<String> getOrCreateChat({
    required String userId,
    required String garageId,
    required String garageName,
    required String garageImage,
  }) async {
    final existingChat = await _firestore
        .collection('chats')
        .where('userId', isEqualTo: userId)
        .where('garageId', isEqualTo: garageId)
        .limit(1)
        .get();

    if (existingChat.docs.isNotEmpty) return existingChat.docs.first.id;

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

  /// Gửi tin nhắn
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String message,
    required bool isFromUser,
    String? imageUrl,
  }) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'imageUrl': imageUrl,
    });

    /// phân biệt user / garage
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'isFromUser': isFromUser,
      'unreadCount': isFromUser ? 0 : FieldValue.increment(1),
    });
  }


  /// Lấy tin nhắn realtime
  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MessageModel.fromMap(doc.id, doc.data()))
        .toList());
  }

  /// Đánh dấu đã đọc
  Future<void> markAsRead(String chatId) async {
    await _firestore.collection('chats').doc(chatId).update({'unreadCount': 0});
  }

  /// Xóa chat và messages
  Future<void> deleteChat(String chatId) async {
    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();
    for (var doc in messages.docs) {
      await doc.reference.delete();
    }
    await _firestore.collection('chats').doc(chatId).delete();
  }
}

