import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:road_assist/domain/entities/message.dart';
import 'package:road_assist/domain/entities/chatuser.dart';

class ChatViewModel extends ChangeNotifier {
  List<Message> _messages = [];
  late ChatUser _user;

  ChatViewModel() {
    _initializeData();
  }

  void _initializeData() {
    _user = ChatUser(
      name: 'Minh Thuan Motor',
      avatar: '🏍️',
    );

    _messages = [
      Message(
        id: 1,
        text: 'Xe của tôi không nổ máy, tôi phải làm sao bây giờ?',
        isSent: false,
        timestamp: '14:05',
      ),
      Message(
        id: 2,
        text: 'Vâng chúng tôi có thể giúp bạn sửa nó, bạn đến garage được chứ?',
        isSent: true,
        timestamp: '14:07',
      ),
      Message(
        id: 3,
        text: 'Tôi có thể đến lúc mấy giờ? vì hiện giờ tôi rất gấp!',
        isSent: false,
        timestamp: '14:08',
      ),
      Message(
        id: 4,
        text: 'Được! chúng tôi sẵn sàng hỗ trợ bạn trong khung giờ từ 7:00 - 19:00!',
        isSent: true,
        timestamp: '14:10',
      ),
      Message(
        id: 5,
        text: 'Bạn có thể đến đây và để lại xe khi nào kiểm tra xong chúng tôi sẽ báo giá và nếu thấy phù hợp bạn có thể phản hồi với chúng tôi nhé! 💯',
        isSent: true,
        timestamp: '14:10',
      ),
      Message(
        id: 6,
        text: 'Được vậy tôi sẽ đến nhờ bạn kiểm tra dùm tôi nhé!',
        isSent: false,
        timestamp: '14:10',
      ),
      Message(
        id: 7,
        text: 'Vâng a!',
        isSent: true,
        timestamp: '14:11',
      ),
      Message(
        id: 8,
        text: 'Xe bạn bị hư cục Bugi nhé!',
        isSent: true,
        timestamp: '15:00',
      ),
      Message(
        id: 9,
        text: 'Chi phí của 1 cục bugi là 230k tính luôn công sửa xe bạn nhé!',
        isSent: true,
        timestamp: '15:00',
      ),
      Message(
        id: 10,
        text: 'Được vậy tiến hành sửa cho mình nhé! khi nào thì mình lấy được?',
        isSent: false,
        timestamp: '15:15',
      ),
      Message(
        id: 11,
        text: 'Sáng mai 7:00 sáng bạn có thể đến lấy nhé!',
        isSent: true,
        timestamp: '15:18',
      ),
      Message(
        id: 12,
        text: 'Oke bạn nhé!',
        isSent: false,
        timestamp: '15:15',
      ),
    ];
  }

  List<Message> get messages => _messages;
  ChatUser get user => _user;

  void addMessage(String text, bool isSent) {
    if (text.trim().isEmpty) return;

    final now = DateTime.now();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    final newMessage = Message(
      id: _messages.length + 1,
      text: text,
      isSent: isSent,
      timestamp: time,
    );

    _messages.add(newMessage);
    notifyListeners();
  }
}