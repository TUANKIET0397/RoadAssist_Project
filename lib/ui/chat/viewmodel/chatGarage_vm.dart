import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/chat_model.dart';
import 'package:road_assist/data/models/message_model.dart';

/// =====================
/// Chat State
/// =====================
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
      error: error ?? this.error,
    );
  }
}

/// =====================
/// Chat Notifier
/// =====================
class ChatNotifier extends StateNotifier<ChatState> {
  final String currentUserId;
  final FirebaseFirestore _firestore;

  StreamSubscription<QuerySnapshot>? _messageSubscription;

  ChatNotifier({
    required this.currentUserId,
    required ChatModel chat,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       super(ChatState(chat: chat, messages: [])) {
    _listenMessages();
  }

  /// Lắng nghe messages realtime
  void _listenMessages() {
    state = state.copyWith(isLoading: true);

    _messageSubscription = _firestore
        .collection('chats')
        .doc(state.chat.id)
        .collection('messages')
        .orderBy('timestamp', descending: false)
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
                .where((m) => m.timestamp.millisecondsSinceEpoch > 0)
                .toList();

            state = state.copyWith(messages: messages, isLoading: false);
          },
          onError: (error) {
            state = state.copyWith(isLoading: false, error: error.toString());
          },
        );
  }

  /// Gửi tin nhắn
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final now = DateTime.now();

    final message = MessageModel(
      id: '',
      chatId: state.chat.id,
      senderId: currentUserId,
      senderName: 'Bạn',
      message: text.trim(),
      timestamp: now,
      isRead: false,
    );

    final chatRef = _firestore.collection('chats').doc(state.chat.id);

    try {
      await chatRef.collection('messages').add(message.toMap());

      await chatRef.update({'isFromUser': true});
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Đánh dấu đã đọc
  Future<void> markAsRead() async {
    final batch = _firestore.batch();

    final messagesRef = _firestore
        .collection('chats')
        .doc(state.chat.id)
        .collection('messages');

    final unreadMessages = await messagesRef
        .where('senderId', isNotEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    batch.update(_firestore.collection('chats').doc(state.chat.id), {
      'unreadCount': 0,
    });

    await batch.commit();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}

/// Providers

/// User hiện tại (sau này lấy từ Auth)
final currentUserIdProvider = Provider<String>((ref) => 'currentUser123');

/// Chat Provider cho từng phòng chat
final chatProvider =
    StateNotifierProvider.family<ChatNotifier, ChatState, ChatModel>((
      ref,
      chat,
    ) {
      final userId = ref.watch(currentUserIdProvider);
      return ChatNotifier(currentUserId: userId, chat: chat);
    });
