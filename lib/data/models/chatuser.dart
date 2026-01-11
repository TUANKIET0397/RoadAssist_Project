class ChatUser {
  final String name;
  final String avatar;
  final String status;

  ChatUser({
    required this.name,
    required this.avatar,
    this.status = 'online',
  });
}
