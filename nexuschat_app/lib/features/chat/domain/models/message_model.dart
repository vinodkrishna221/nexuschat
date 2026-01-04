enum MessageStatus { sent, delivered, read }

class MessageModel {
  final String id;
  final String text;
  final String senderId;
  final DateTime timestamp;
  final MessageStatus status;
  final bool isMe;

  const MessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.timestamp,
    required this.status,
    required this.isMe,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    final sender = json['sender'];
    final senderId = sender is Map ? sender['_id'] : (sender ?? '');
    
    MessageStatus status = MessageStatus.sent;
    if (json['status'] == 'read') status = MessageStatus.read;
    else if (json['status'] == 'delivered') status = MessageStatus.delivered;

    return MessageModel(
      id: json['_id'] ?? json['id'] ?? '',
      text: json['content'] ?? '',
      senderId: senderId,
      timestamp: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      status: status,
      isMe: senderId == currentUserId,
    );
  }

  static List<MessageModel> dummyMessages = [
    MessageModel(
      id: '1',
      text: 'Hey there! How is the project going?',
      senderId: '1',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      status: MessageStatus.read,
      isMe: false,
    ),
    MessageModel(
      id: '2',
      text: 'It is going great! I just finished the chat list implementation.',
      senderId: 'me',
      timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
      status: MessageStatus.read,
      isMe: true,
    ),
    MessageModel(
      id: '3',
      text: 'That is awesome! Can I see a screenshot?',
      senderId: '1',
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      status: MessageStatus.read,
      isMe: false,
    ),
    MessageModel(
      id: '4',
      text: 'Sure, let me send it to you.',
      senderId: 'me',
      timestamp: DateTime.now().subtract(const Duration(minutes: 7)),
      status: MessageStatus.delivered,
      isMe: true,
    ),
    MessageModel(
      id: '5',
      text: 'Glassmorphism looks really cool by the way.',
      senderId: 'me',
      timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
      status: MessageStatus.sent,
      isMe: true,
    ),
  ];
}
