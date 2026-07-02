enum MessageSender { user, agent }

enum MessageType { text, audio, image, document }

class Message {
  final String id;
  final String conversationId;
  final String content;
  final MessageSender sender;
  final String agentType;
  final DateTime timestamp;
  final MessageType type;

  const Message({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.sender,
    this.agentType = '',
    required this.timestamp,
    this.type = MessageType.text,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String? ?? '',
      conversationId: json['conversationId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      sender: _parseSender(json['sender'] as String? ?? 'user'),
      agentType: json['agentType'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      type: _parseType(json['type'] as String? ?? 'text'),
    );
  }

  static MessageSender _parseSender(String value) {
    return MessageSender.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MessageSender.user,
    );
  }

  static MessageType _parseType(String value) {
    return MessageType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MessageType.text,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'content': content,
      'sender': sender.name,
      'agentType': agentType,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
    };
  }

  Message copyWith({
    String? id,
    String? conversationId,
    String? content,
    MessageSender? sender,
    String? agentType,
    DateTime? timestamp,
    MessageType? type,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      agentType: agentType ?? this.agentType,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Message(id: $id, sender: ${sender.name}, type: ${type.name})';
}
