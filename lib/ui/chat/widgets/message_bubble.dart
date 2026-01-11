import 'package:flutter/material.dart';
import 'package:road_assist/data/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? const Color(0xFF050D23)
                    : const Color(0xFF051F4F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildContent(),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748b),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (message.type == 'image' && message.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          message.imageUrl!,
          width: 200,
          fit: BoxFit.cover,
        ),
      );
    }

    return Text(
      message.text ?? '',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        height: 1.4,
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }
}
