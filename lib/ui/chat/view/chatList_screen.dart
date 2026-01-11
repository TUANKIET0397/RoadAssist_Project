import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/chat_model.dart';
import 'package:road_assist/ui/chat/viewmodel/chatList_vm.dart';
import 'package:road_assist/ui/chat/view/chatGarage_screen.dart';

class ChatListScreen extends ConsumerWidget {
  final String userId;
  const ChatListScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatStream = ref.watch(chatStreamProvider(userId));

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(56, 56, 224, 1),
            Color.fromRGBO(46, 144, 183, 1),
          ],
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),

          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: chatStream.when(
                data: (chats) {
                  if (chats.isEmpty) return _buildEmptyState();
                  return _buildChatList(context, ref, chats);
                },
                loading: () => const Center(
                  child:
                  CircularProgressIndicator(color: Color(0xFF4A90E2)),
                ),
                error: (err, _) => Center(
                  child: Text(
                    'Lỗi: $err',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // HEADER

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(37, 44, 59, 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Chat garage',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFF34C8E8), Color(0xFF4E4AF2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 16),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  //Chat List

  Widget _buildChatList(
      BuildContext context,
      WidgetRef ref,
      List<ChatModel> chats,
      ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 120),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        final unreadCount = chat.unread[userId] ?? 0;

        return ChatItem(
          name: chat.garageName,
          message: chat.lastMessage,
          time: formatTime(chat.lastMessageTime),
          imageUrl: chat.garageImage,
          unreadCount: unreadCount,
          onTap: () async {
            if (!context.mounted) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(chat: chat),
              ),
            );
          },
        );
      },
    );
  }

  //empty list

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/illustrations/nochat.png',
            width: 300,
            height: 300,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(fontSize: 18, color: Colors.white, height: 1.5),
              children: [
                TextSpan(text: 'Bạn chưa có cuộc trò chuyện nào '),
                TextSpan(
                  text: 'với Garage',
                  style: TextStyle(
                    color: Color(0xFF37B6E9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Khi gửi yêu cầu cứu hộ, bạn có thể trò chuyện\ntrực tiếp với Garage',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // time

  String formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút';
    if (diff.inHours < 24) return '${diff.inHours} giờ';
    if (diff.inDays < 7) return '${diff.inDays} ngày';
    return '${time.day}/${time.month}/${time.year}';
  }
}

// chat item

class ChatItem extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final String imageUrl;
  final int unreadCount;
  final VoidCallback onTap;

  const ChatItem({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    required this.imageUrl,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF34495E).withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF4A90E2).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 12),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Center(
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight:
                    unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                time,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: unreadCount > 0 ? Colors.white : Colors.grey[300],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
