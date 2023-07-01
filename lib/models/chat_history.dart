class ChatHistory {
  String? senderId;
  String? recipientId;
  String? message;
  String? time;

  ChatHistory({this.senderId, this.recipientId, this.message, this.time});

  ChatHistory.fromJson(Map<String, dynamic> json) {
    senderId = json['sender_id'];
    recipientId = json['recipient_id'];
    message = json['message'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sender_id'] = senderId;
    data['recipient_id'] = recipientId;
    data['message'] = message;
    data['time'] = time;
    return data;
  }
}
