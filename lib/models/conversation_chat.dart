class ConversationMessage {
  String? roomName;
  String? roomAvt;
  String? roomId;
  bool? isGroup;
  ChatMessage? chatMessage;

  ConversationMessage(
      {this.roomName,
      this.roomAvt,
      this.roomId,
      this.isGroup,
      this.chatMessage});

  ConversationMessage.fromJson(Map<String, dynamic> json) {
    roomName = json['room_name'];
    roomAvt = json['room_avt'];
    roomId = json['room_id'];
    isGroup = json['is_group'];
    chatMessage = json['chat_message'] != null
        ? ChatMessage.fromJson(json['chat_message'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['room_name'] = roomName;
    data['room_avt'] = roomAvt;
    data['room_id'] = roomId;
    data['is_group'] = isGroup;
    if (chatMessage != null) {
      data['chat_message'] = chatMessage!.toJson();
    }
    return data;
  }
}

class ChatMessage {
  String? senderId;
  String? recipientId;
  String? message;
  String? time;
  String? resourceType;

  ChatMessage(
      {this.senderId,
      this.recipientId,
      this.message,
      this.time,
      this.resourceType});

  ChatMessage.fromJson(Map<String, dynamic> json) {
    senderId = json['sender_id'];
    recipientId = json['recipient_id'];
    message = json['message'];
    time = json['time'];
    resourceType = json['resource_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sender_id'] = senderId;
    data['recipient_id'] = recipientId;
    data['message'] = message;
    data['time'] = time;
    data['resource_type'] = resourceType;
    return data;
  }
}
