import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/providers/auth_provider.dart';
import 'package:road_assist/core/theme/app_palette.dart';

import 'package:road_assist/data/models/chat_model.dart';
import 'package:road_assist/ui/call/extensions/call_extension.dart';
import 'package:road_assist/ui/user/chat/viewmodel/chatGarage_vm.dart';

import 'package:road_assist/ui/user/chat/widgets/date_divider.dart';
import 'package:road_assist/ui/user/chat/widgets/message_bubble.dart';
import 'package:road_assist/ui/shared/skeleton/skeleton_widgets.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatBoxProvider(widget.chatId).notifier).markAsRead();
    });

    ref.listenManual(chatBoxProvider(widget.chatId), (prev, next) {
      if (prev == null) return;
      if (prev.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;

    final max = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(
        max,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(max);
    }
  }

  void _sendMessage(ChatNotifier notifier) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    notifier.sendTextMessage(text);
    _textController.clear();

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatBoxProvider(widget.chatId));
    final chatNotifier = ref.read(chatBoxProvider(widget.chatId).notifier);
    final currentUserId = ref.watch(userIdProvider);

    final chatContent = Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(chatState.chat, currentUserId),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppPalette.bgColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(child: _buildMessages(chatState, chatNotifier)),
              _buildInput(chatNotifier),
            ],
          ),
        ),
      ),
    );

    // Return scaffold directly - IncomingCallListener is at the main screen level
    return chatContent;
  }

  PreferredSizeWidget _buildAppBar(ChatModel? chat, String? currentUserId) {
    final otherParticipant = chat?.getOtherParticipant(currentUserId!);

    return AppBar(
      backgroundColor: const Color.fromRGBO(37, 44, 59, 1),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: chat == null
          ? const SizedBox.shrink()
          : Row(
              children: [
                _buildAvatar(otherParticipant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    otherParticipant?.name ?? 'Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
      actions: [
        // Call button - nằm trong AppBar
        if (otherParticipant != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  context.callGarage(
                    otherParticipant.uid,
                    garageName: otherParticipant.name,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3b82f6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.call, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatar(Participant? participant) {
    final img = participant?.avatar;
    final hasAvatar = img != null && img.isNotEmpty;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF475569),
        image: DecorationImage(
          image: hasAvatar
              ? NetworkImage(img)
              : const AssetImage(
                      'assets/images/illustrations/avatarDefault.png',
                    )
                    as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildMessages(ChatState state, ChatNotifier notifier) {
    if (state.isLoading) {
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return SkeletonMessageBubble(isMe: index % 2 == 0);
        },
      );
    }

    if (state.error != null) {
      return Center(
        child: Text(
          state.error!,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    if (state.messages.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có tin nhắn nào',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final msg = state.messages[index];
        final isMe = msg.senderId == notifier.userId;

        bool showDate =
            index == 0 ||
            !_isSameDay(state.messages[index - 1].createdAt, msg.createdAt);

        return Column(
          children: [
            if (showDate) DateDivider(date: msg.createdAt),
            MessageBubble(message: msg, isMe: isMe),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  Widget _buildInput(ChatNotifier notifier) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
      decoration: const BoxDecoration(color: Color(0xFF201C4C)),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Aa',
                  hintStyle: TextStyle(color: Color(0xFF475569)),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(notifier),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF34C8E8)),
            onPressed: () => _sendMessage(notifier),
          ),
        ],
      ),
    );
  }
}
