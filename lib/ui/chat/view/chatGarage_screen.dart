import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/chat_model.dart';
import 'package:road_assist/data/models/message_model.dart';
import 'package:road_assist/ui/chat/viewmodel/chatGarage_vm.dart';

import 'package:road_assist/ui/chat/widgets/date_divider.dart';
import 'package:road_assist/ui/chat/widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final ChatModel chat;

  const ChatScreen({super.key, required this.chat});

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
      ref.read(chatProvider(widget.chat).notifier).markAsRead();
    });

    ref.listenManual(chatProvider(widget.chat), (prev, next) {
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

    notifier.sendMessage(text);
    _textController.clear();

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider(widget.chat));
    final chatNotifier = ref.read(chatProvider(widget.chat).notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(56, 56, 224, 1),
              Color.fromRGBO(46, 144, 183, 1),
            ],
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
  }

  // APP BAR

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(37, 44, 59, 1),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.chat.garageName,
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
        IconButton(
          icon: const Icon(Icons.call, color: Color(0xFF3B82F6)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    final img = widget.chat.garageImage;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF475569),
        image: img.startsWith('http')
            ? DecorationImage(image: NetworkImage(img), fit: BoxFit.cover)
            : null,
      ),
      child: !img.startsWith('http')
          ? Center(
        child: Text(
          img.isNotEmpty ? img[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white),
        ),
      )
          : null,
    );
  }

  // message

  Widget _buildMessages(ChatState state, ChatNotifier notifier) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
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
        final isMe = msg.senderId == notifier.currentUserId;

        bool showDate = false;
        if (index == 0) {
          showDate = true;
        } else {
          final prev = state.messages[index - 1];
          showDate = !_isSameDay(prev.createdAt, msg.createdAt);
        }

        return Column(
          children: [
            if (showDate) DateDivider(date: msg.createdAt),
            MessageBubble(
              message: msg,
              isMe: isMe,
            ),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year &&
        d1.month == d2.month &&
        d1.day == d2.day;
  }

  Widget _buildDateSeparator(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          '${date.day.toString().padLeft(2, '0')}/'
              '${date.month.toString().padLeft(2, '0')}/'
              '${date.year}',
          style: const TextStyle(
            color: Color(0xFF34CAE8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }


  // input

  Widget _buildInput(ChatNotifier notifier) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
      decoration: const BoxDecoration(color: Color(0xFF0D0783)),
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
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
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
