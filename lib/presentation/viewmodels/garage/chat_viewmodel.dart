import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:road_assist/data/models/response/chat_model.dart';
import 'package:road_assist/data/models/response/message_model.dart';



class ChatViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  List<ChatModel> _chats = [];

  bool get isLoading => _isLoading;
  List<ChatModel> get chats => _chats;

  /// Load danh sách chat của user
  Stream<List<ChatModel>> getChatStream(String userId) {
    return _firestore
        .collection('chats')
        .where('userId', isEqualTo: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// Tạo hoặc lấy chat với garage
  Future<String> getOrCreateChat({
    required String userId,
    required String garageId,
    required String garageName,
    required String garageImage,
  }) async {
    try {
      // Kiểm tra xem đã có chat chưa
      final existingChat = await _firestore
          .collection('chats')
          .where('userId', isEqualTo: userId)
          .where('garageId', isEqualTo: garageId)
          .limit(1)
          .get();

      if (existingChat.docs.isNotEmpty) {
        return existingChat.docs.first.id;
      }

      // Tạo chat mới
      final chatRef = await _firestore.collection('chats').add({
        'userId': userId,
        'garageId': garageId,
        'garageName': garageName,
        'garageImage': garageImage,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': 0,
        'isFromUser': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return chatRef.id;
    } catch (e) {
      debugPrint('❌ Lỗi create chat: $e');
      rethrow;
    }
  }

  /// Gửi tin nhắn
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String message,
    String? imageUrl,
  }) async {
    try {
      // Thêm message vào subcollection
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

      // Cập nhật lastMessage trong chat
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'isFromUser': true,
      });

      debugPrint('✅ Đã gửi tin nhắn');
    } catch (e) {
      debugPrint('❌ Lỗi send message: $e');
      rethrow;
    }
  }

  /// Đánh dấu đã đọc
  Future<void> markAsRead(String chatId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount': 0,
      });
    } catch (e) {
      debugPrint('❌ Lỗi mark as read: $e');
    }
  }

  /// Lấy stream messages
  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// Delete chat
  Future<void> deleteChat(String chatId) async {
    try {
      // Xóa tất cả messages
      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      for (var doc in messages.docs) {
        await doc.reference.delete();
      }

      // Xóa chat
      await _firestore.collection('chats').doc(chatId).delete();

      debugPrint('Đã xóa chat');
    } catch (e) {
      debugPrint('Lỗi delete chat: $e');
    }
  }
}