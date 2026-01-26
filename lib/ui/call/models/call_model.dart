enum CallStatus { ringing, accepted, ended }

class CallModel {
  final String id;
  final String channel;
  final String callerId;
  final String receiverId;
  final CallStatus status;

  CallModel({
    required this.id,
    required this.channel,
    required this.callerId,
    required this.receiverId,
    required this.status,
  });

  factory CallModel.fromJson(String id, Map<String, dynamic> json) {
    return CallModel(
      id: id,
      channel: json['channel'],
      callerId: json['callerId'],
      receiverId: json['receiverId'],
      status: CallStatus.values.firstWhere((e) => e.name == json['status']),
    );
  }

  Map<String, dynamic> toJson() => {
    'channel': channel,
    'callerId': callerId,
    'receiverId': receiverId,
    'status': status.name,
  };
}
