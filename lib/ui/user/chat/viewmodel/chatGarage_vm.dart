import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:road_assist/core/auth/auth_state.dart';
import 'package:road_assist/core/providers/auth_provider.dart';
import 'package:road_assist/data/models/chat_model.dart';
import 'package:road_assist/data/models/message_model.dart';

/// CHAT STATE

class ChatState {
  final ChatModel? chat;
  final List<MessageModel> messages;
  final bool isLoading;
  final String? error;

  const ChatState({
    this.chat,
    required this.messages,
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    ChatModel? chat,
    List<MessageModel>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      chat: chat ?? this.chat,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// =======================
/// CHAT NOTIFIER
/// =======================

class ChatNotifier extends StateNotifier<ChatState> {
  final FirebaseFirestore _firestore;
  final String chatId;
  final String userId;
  final UserRole role;

  StreamSubscription<DocumentSnapshot>? _chatSub;
  StreamSubscription<QuerySnapshot>? _messageSub;

  ChatNotifier({
    required this.chatId,
    required this.userId,
    required this.role,
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        super(const ChatState(messages: [], isLoading: true)) {
    _listenChat();
    _listenMessages();
  }

  /// =======================
  /// LISTEN CHAT INFO
  /// =======================

  void _listenChat() {
    _chatSub = _firestore
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .listen(
          (snapshot) {
        if (!snapshot.exists) return;

        final chat = ChatModel.fromMap(snapshot.id, snapshot.data()!);
        state = state.copyWith(chat: chat);
      },
      onError: (e) {
        state = state.copyWith(error: e.toString());
      },
    );
  }

  /// =======================
  /// LISTEN MESSAGES
  /// =======================

  void _listenMessages() {
    _messageSub = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .listen(
          (snapshot) {
        final messages = snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.id, doc.data()))
            .toList();

        state = state.copyWith(
          messages: messages,
          isLoading: false,
        );
      },
      onError: (e) {
        state = state.copyWith(
          error: e.toString(),
          isLoading: false,
        );
      },
    );
  }

  /// =======================
  /// SEND MESSAGE
  /// =======================

  Future<void> sendTextMessage(String text) async {
    final content = text.trim();
    if (content.isEmpty) return;

    final now = DateTime.now();
    final chatRef = _firestore.collection('chats').doc(chatId);
    final messageRef = chatRef.collection('messages').doc();

    final sender = role == UserRole.customer ? 'customer' : 'garage';
    final receiver = role == UserRole.customer ? 'garage' : 'customer';

    final message = MessageModel(
      id: messageRef.id,
      senderId: userId,
      senderRole: sender,
      type: 'text',
      text: content,
      imageUrl: null,
      createdAt: now,
      readBy: [userId],
    );

    await _firestore.runTransaction((tx) async {
      tx.set(messageRef, message.toMap());

      tx.update(chatRef, {
        'lastMessage': content,
        'lastMessageTime': Timestamp.fromDate(now),
        'lastSenderId': userId,
        'lastSenderRole': sender,

        'unread.$receiver': FieldValue.increment(1),
      });
    });
  }


  /// =======================
  /// SEND CALL HISTORY MESSAGE
  /// =======================

  Future<void> sendCallHistoryMessage({
    required int durationSeconds,
  }) async {
    final now = DateTime.now();
    final chatRef = _firestore.collection('chats').doc(chatId);
    final messageRef = chatRef.collection('messages').doc();

    final sender = role == UserRole.customer ? 'customer' : 'garage';
    final receiver = role == UserRole.customer ? 'garage' : 'customer';

    // Format duration
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    final durationText = minutes > 0 
        ? '$minutes phút ${seconds}s'
        : '$seconds giây';
    
    final callHistoryText = '📞 Cuộc gọi đã kết thúc. Thời lượng: $durationText';

    final message = MessageModel(
      id: messageRef.id,
      senderId: userId,
      senderRole: sender,
      type: 'text',
      text: callHistoryText,
      imageUrl: null,
      createdAt: now,
      readBy: [userId],
    );

    await _firestore.runTransaction((tx) async {
      tx.set(messageRef, message.toMap());

      tx.update(chatRef, {
        'lastMessage': callHistoryText,
        'lastMessageTime': Timestamp.fromDate(now),
        'lastSenderId': userId,
        'lastSenderRole': sender,

        'unread.$receiver': FieldValue.increment(1),
      });
    });
  }

  /// =======================
  /// MARK AS READ
  /// =======================

  Future<void> markAsRead() async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    final messagesRef = chatRef.collection('messages');

    final snapshot = await messagesRef
        .where('senderId', isNotEqualTo: userId)
        .get();

    if (snapshot.docs.isEmpty) return;

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

  @override
  void dispose() {
    _chatSub?.cancel();
    _messageSub?.cancel();
    super.dispose();
  }
}

/// =======================
/// PROVIDER
/// =======================

final chatBoxProvider = StateNotifierProvider.family<
    ChatNotifier, ChatState, String>((ref, chatId) {
  final auth = ref.watch(authStateProvider);

  if (!auth.isLoggedIn ||
      !auth.isInitialized ||
      auth.userId == null ||
      auth.role == null) {
    throw Exception('User not authenticated');
  }

  return ChatNotifier(
    chatId: chatId,
    userId: auth.userId!,
    role: auth.role!,
  );
});
