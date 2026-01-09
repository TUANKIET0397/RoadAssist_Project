import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/response/chat_model.dart';
import 'package:road_assist/presentation/views/chat/viewmodel/chatList_vm.dart';

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
          // Header full status bar
          Container(
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
          ),

          // Body: Chat list
          Expanded(
            child: SafeArea(
              top: false, // header đã xử lý top
              bottom: false,
              child: chatStream.when(
                data: (chats) {
                  if (chats.isEmpty) return _buildEmptyState();

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 120),
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      return ChatItem(
                        name: chat.garageName,
                        message: chat.lastMessage,
                        time: chat.lastMessageTime != null
                            ? formatTime(chat.lastMessageTime)
                            : '',
                        imageUrl: chat.garageImage,
                        unreadCount: chat.unreadCount,
                        onTap: () async {
                          final chatId = await ref
                              .read(chatRepositoryProvider)
                              .getOrCreateChat(
                            userId: userId,
                            garageId: chat.garageId,
                            garageName: chat.garageName,
                            garageImage: chat.garageImage,
                          );

                          // TODO: Navigate to ChatDetailScreen
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF4A90E2),
                  ),
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

          // Text với gradient
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                height: 1.5,
              ),
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
                color: Colors.white.withOpacity(0.6),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${time.day}/${time.month}/${time.year}';
  }
}

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
            // Avatar
            Stack(
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
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
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
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: unreadCount > 0 ? Colors.white : Colors.grey[300],
                      fontSize: 14,
                      fontWeight:
                          unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
