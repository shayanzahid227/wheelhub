class ChatMessage {
  final String id;
  final String vehicleId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.vehicleId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.sentAt,
  });
}

class ChatThread {
  final String vehicleId;
  final String vehicleTitle;
  final String sellerId;
  final String sellerName;
  final String sellerPhone;
  final List<ChatMessage> messages;

  const ChatThread({
    required this.vehicleId,
    required this.vehicleTitle,
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhone,
    required this.messages,
  });

  ChatThread copyWith({List<ChatMessage>? messages}) {
    return ChatThread(
      vehicleId: vehicleId,
      vehicleTitle: vehicleTitle,
      sellerId: sellerId,
      sellerName: sellerName,
      sellerPhone: sellerPhone,
      messages: messages ?? this.messages,
    );
  }
}
