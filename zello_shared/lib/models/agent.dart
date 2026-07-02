enum AgentType { medico, psicologo }

enum AgentStatus { online, offline, busy }

class Agent {
  final String id;
  final String name;
  final AgentType type;
  final AgentStatus status;
  final int activeConversations;
  final int totalHandled;
  final double avgResponseTime;

  const Agent({
    required this.id,
    required this.name,
    required this.type,
    this.status = AgentStatus.offline,
    this.activeConversations = 0,
    this.totalHandled = 0,
    this.avgResponseTime = 0.0,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: _parseType(json['type'] as String? ?? 'medico'),
      status: _parseStatus(json['status'] as String? ?? 'offline'),
      activeConversations: (json['activeConversations'] as num?)?.toInt() ?? 0,
      totalHandled: (json['totalHandled'] as num?)?.toInt() ?? 0,
      avgResponseTime: (json['avgResponseTime'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static AgentType _parseType(String value) {
    return AgentType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AgentType.medico,
    );
  }

  static AgentStatus _parseStatus(String value) {
    return AgentStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AgentStatus.offline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'status': status.name,
      'activeConversations': activeConversations,
      'totalHandled': totalHandled,
      'avgResponseTime': avgResponseTime,
    };
  }

  Agent copyWith({
    String? id,
    String? name,
    AgentType? type,
    AgentStatus? status,
    int? activeConversations,
    int? totalHandled,
    double? avgResponseTime,
  }) {
    return Agent(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      activeConversations: activeConversations ?? this.activeConversations,
      totalHandled: totalHandled ?? this.totalHandled,
      avgResponseTime: avgResponseTime ?? this.avgResponseTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Agent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Agent(id: $id, name: $name, type: ${type.name}, status: ${status.name})';
}
