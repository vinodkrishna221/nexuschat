class ChatModel {
  final String id;
  final String name;
  final String avatarUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  const ChatModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    final participant = json['participant'];
    String name = 'Unknown';
    String avatar = 'https://i.pravatar.cc/150';
    bool isOnline = false;

    if (participant != null) {
      name = participant['displayName'] ?? participant['username'] ?? 'Unknown';
      avatar = participant['avatar'] ?? avatar;
      isOnline = participant['isOnline'] ?? false;
    }

    return ChatModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? name,
      avatarUrl: json['avatarUrl'] ?? avatar,
      lastMessage: json['lastMessage'] is Map 
          ? (json['lastMessage']['content'] ?? '') 
          : (json['lastMessage'] ?? ''),
      lastMessageTime: json['lastActivity'] != null 
          ? DateTime.parse(json['lastActivity']) 
          : (json['updatedAt'] != null 
              ? DateTime.parse(json['updatedAt']) 
              : DateTime.now()),
      unreadCount: json['unreadCount'] ?? 0,
      isOnline: isOnline,
    );
  }

  static List<ChatModel> dummyChats = [
    ChatModel(
      id: '1',
      name: 'Alice Smith',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      lastMessage: 'Hey, how are you doing?',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 2,
      isOnline: true,
    ),
    ChatModel(
      id: '2',
      name: 'Bob Johnson',
      avatarUrl: 'https://i.pravatar.cc/150?img=2',
      lastMessage: 'Can we meet tomorrow?',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      unreadCount: 0,
      isOnline: false,
    ),
    ChatModel(
      id: '3',
      name: 'Charlie Brown',
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
      lastMessage: 'The project looks great!',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 5,
      isOnline: true,
    ),
    ChatModel(
      id: '4',
      name: 'David Wilson',
      avatarUrl: 'https://i.pravatar.cc/150?img=4',
      lastMessage: 'Sent you the files.',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
      unreadCount: 0,
      isOnline: false,
    ),
    ChatModel(
      id: '5',
      name: 'Eva Green',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      lastMessage: 'Thanks!',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 5)),
      unreadCount: 0,
      isOnline: true,
    ),
  ];
}
