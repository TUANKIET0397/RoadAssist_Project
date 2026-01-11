class Message {
  final int id;
  final String text;
  final bool isSent;
  final String timestamp;

  Message({
    required this.id,
    required this.text,
    required this.isSent,
    required this.timestamp,
  });
}
