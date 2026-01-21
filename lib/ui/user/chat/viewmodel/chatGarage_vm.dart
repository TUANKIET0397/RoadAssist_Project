import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/chat_model.dart';
import 'package:road_assist/data/models/message_model.dart';
import 'package:road_assist/core/providers/auth_provider.dart';

/// Chat State
class ChatState {
  final ChatModel chat;
  final List<MessageModel> messages;
  final bool isLoading;
  final String? error;

  const ChatState({
    required this.chat,
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

/// Chat Notifier
class ChatNotifier extends StateNotifier<ChatState> {
  final FirebaseFirestore _firestore;
  final String? currentUserId;
  final String senderRole;

  StreamSubscription<QuerySnapshot>? _messageSub;

  ChatNotifier({
    required ChatModel chat,
    required this.currentUserId,
    required this.senderRole,
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        super(ChatState(chat: chat, messages: [], isLoading: true)) {
    final id = currentUserId;
    if (id == null || id.isEmpty) {
      state = state.copyWith(error: "User not logged in.", isLoading: false);
      return;
    }
    _listenMessages();
  }

  /// Listen messages realtime
  void _listenMessages() {
    final id = currentUserId;
    if (id == null || id.isEmpty) return;

    state = state.copyWith(isLoading: true);

    _messageSub = _firestore
        .collection('chats')
        .doc(state.chat.id)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen(
          (snapshot) {
        final messages = snapshot.docs
            .map(
              (doc) => MessageModel.fromMap(
            doc.id,
            doc.data() as Map<String, dynamic>,
          ),
        )
            .toList();

        state = state.copyWith(
          messages: messages,
          isLoading: false,
        );
      },
      onError: (e) {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
        );
      },
    );
  }


  /// Send text message
  Future<void> sendMessage(String text) async {
    final content = text.trim();
    if (content.isEmpty) return;

    final id = currentUserId;
    if (id == null || id.isEmpty) {
      state = state.copyWith(error: "User not logged in");
      return;
    }

    final now = DateTime.now();
    final chatRef = _firestore.collection('chats').doc(state.chat.id);
    final messageRef = chatRef.collection('messages').doc();

    final message = MessageModel(
      id: messageRef.id,
      senderId: id,
      senderRole: senderRole,
      type: 'text',
      text: content,
      imageUrl: null,
      createdAt: now,
      readBy: [id],
    );

    try {
      await _firestore.runTransaction((transaction) async {
        transaction.set(messageRef, message.toMap());

        if (senderRole == 'garage') {
          transaction.update(chatRef, {
            'lastMessage': content,
            'lastMessageTime': Timestamp.fromDate(now),
            'lastSenderId': id,
            'unreadCount': FieldValue.increment(1),
          });
        }
      });
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }



  /// Mark messages as read
  Future<void> markAsRead() async {
    final id = currentUserId;
    if (id == null || id.isEmpty) return;

    final chatRef = _firestore.collection('chats').doc(state.chat.id);
    final messagesRef = chatRef.collection('messages');

    final snapshot = await messagesRef
        .where('senderId', isNotEqualTo: id)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    bool hasUpdate = false;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final List<dynamic> readBy = data['readBy'] ?? [];

      if (!readBy.contains(id)) {
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([id]),
        });
        hasUpdate = true;
      }
    }

    if (hasUpdate) {
      batch.update(chatRef, {'unreadCount': 0});
      await batch.commit();
    }
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    super.dispose();
  }
}

/// Providers

final chatProvider = StateNotifierProvider.family<
    ChatNotifier, ChatState, ChatModel>((ref, chat) {

  final userId = ref.watch(userIdProvider);

  return ChatNotifier(
    chat: chat,
    currentUserId: userId ?? '',
    senderRole: 'user',
  );
});
