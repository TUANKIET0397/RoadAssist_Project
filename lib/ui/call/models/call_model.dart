class CallModel {
  final String callId; //id phòng gọi
  final String callerId;
  final String receiverId;
  final String status; //calling | accepted | ended

  CallModel({
    required this.callId,
    required this.callerId,
    required this.receiverId,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
    'callerId': callerId,
    'receiverId': receiverId,
    'status': status,
  };
}
