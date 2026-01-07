import 'package:flutter/material.dart';

class ChatGarageScreen extends StatefulWidget {
  const ChatGarageScreen({super.key});

  @override
  State<ChatGarageScreen> createState() => _ChatGarageScreenState();
}

class _ChatGarageScreenState extends State<ChatGarageScreen> {
  final List<Map<String, dynamic>> chatList = [
    {
      'name': 'Garage Minh Thuan',
      'message': 'Hello có gì không á?',
      'time': '5 m ago',
      'image': 'https://images.unsplash.com/photo-1625231334168-35067f8853ed?w=200',
      'unread': 0,
    },
    {
      'name': 'Motor Kiet',
      'message': 'Xe bạn đỡ sửa xong!',
      'time': '5 m ago',
      'image': 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=200',
      'unread': 2,
    },
    {
      'name': 'Nhà xe Mạnh đuck',
      'message': 'ai biết đâu?',
      'time': '5 m ago',
      'image': 'https://images.unsplash.com/photo-1625047509168-a7026f36de04?w=200',
      'unread': 0,
    },
    {
      'name': 'Gia bảo xe điện',
      'message': 'không',
      'time': '5 m ago',
      'image': 'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=200',
      'unread': 0,
    },
    {
      'name': 'Minh Thuan Tài xế',
      'message': 'đang ở nha nhé',
      'time': '5 m ago',
      'image': 'https://images.unsplash.com/photo-1632823469211-fa7e0a8f81fd?w=200',
      'unread': 1,
    },
    {
      'name': 'Tuan kiet BUGI',
      'message': 'oke tới đi!',
      'time': '5 m ago',
      'image': 'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=200',
      'unread': 0,
    },
    {
      'name': 'Duc manh xe',
      'message': 'Có á',
      'time': '5 m ago',
      'image': 'https://images.unsplash.com/photo-1632823469850-1b7b1b3c3c6d?w=200',
      'unread': 0,
    },
    {
      'name': 'Duc manh xe',
      'message': 'Có á',
      'time': '5 m ago',
      'image': 'https://images.unsplash.com/photo-1632823469211-fa7e0a8f81fd?w=200',
      'unread': 3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a2332),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(45, 55, 80, 0.6),
                Color.fromRGBO(30, 10, 160, 0.6),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                  decoration: const BoxDecoration(
                  color: Color.fromRGBO(50, 65, 85, 0.7),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chat garage',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF34C8E8),
                              Color(0xFF4E4AF2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            // TODO: Implement search
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Chat List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: chatList.length,
                  itemBuilder: (context, index) {
                    final chat = chatList[index];
                    return ChatItem(
                      name: chat['name'],
                      message: chat['message'],
                      time: chat['time'],
                      imageUrl: chat['image'],
                      unreadCount: chat['unread'],
                      onTap: () {
                        // TODO: Navigate to chat detail screen
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1220),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),

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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
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
