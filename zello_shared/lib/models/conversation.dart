import 'agent.dart';

enum ConversationStatus { active, waiting, closed }

class Conversation {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String lastMessage;
  final DateTime lastMessageTime;
  final AgentType agentType;
  final ConversationStatus status;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    this.lastMessage = '',
    required this.lastMessageTime,
    this.agentType = AgentType.medico,
    this.status = ConversationStatus.active,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      userPhone: json['userPhone'] as String? ?? '',
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.tryParse(json['lastMessageTime'] as String) ??
              DateTime.now()
          : DateTime.now(),
      agentType: _parseAgentType(json['agentType'] as String? ?? 'medico'),
      status: _parseStatus(json['status'] as String? ?? 'active'),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }

  static AgentType _parseAgentType(String value) {
    return AgentType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AgentType.medico,
    );
  }

  static ConversationStatus _parseStatus(String value) {
    return ConversationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ConversationStatus.active,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'agentType': agentType.name,
      'status': status.name,
      'unreadCount': unreadCount,
    };
  }

  Conversation copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhone,
    String? lastMessage,
    DateTime? lastMessageTime,
    AgentType? agentType,
    ConversationStatus? status,
    int? unreadCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      agentType: agentType ?? this.agentType,
      status: status ?? this.status,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Conversation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Conversation(id: $id, userName: $userName, status: ${status.name})';
}
