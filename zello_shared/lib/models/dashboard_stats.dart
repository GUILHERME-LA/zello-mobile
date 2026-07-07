class DashboardStats {
  final int activeConversations;
  final int totalPatients;
  final int agentsOnline;
  final double avgResponseTime;
  final int unassignedPatients;

  const DashboardStats({
    this.activeConversations = 0,
    this.totalPatients = 0,
    this.agentsOnline = 0,
    this.avgResponseTime = 0.0,
    this.unassignedPatients = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      activeConversations: (json['activeConversations'] as num?)?.toInt() ?? 0,
      totalPatients: (json['totalPatients'] as num?)?.toInt() ?? 0,
      agentsOnline: (json['agentsOnline'] as num?)?.toInt() ?? 0,
      avgResponseTime: (json['avgResponseTime'] as num?)?.toDouble() ?? 0.0,
      unassignedPatients: (json['unassignedPatients'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activeConversations': activeConversations,
      'totalPatients': totalPatients,
      'agentsOnline': agentsOnline,
      'avgResponseTime': avgResponseTime,
      'unassignedPatients': unassignedPatients,
    };
  }

  DashboardStats copyWith({
    int? activeConversations,
    int? totalPatients,
    int? agentsOnline,
    double? avgResponseTime,
    int? unassignedPatients,
  }) {
    return DashboardStats(
      activeConversations: activeConversations ?? this.activeConversations,
      totalPatients: totalPatients ?? this.totalPatients,
      agentsOnline: agentsOnline ?? this.agentsOnline,
      avgResponseTime: avgResponseTime ?? this.avgResponseTime,
      unassignedPatients: unassignedPatients ?? this.unassignedPatients,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardStats &&
        other.activeConversations == activeConversations &&
        other.totalPatients == totalPatients &&
        other.agentsOnline == agentsOnline &&
        other.avgResponseTime == avgResponseTime &&
        other.unassignedPatients == unassignedPatients;
  }

  @override
  int get hashCode => Object.hash(
        activeConversations,
        totalPatients,
        agentsOnline,
        avgResponseTime,
        unassignedPatients,
      );

  @override
  String toString() =>
      'DashboardStats(active: $activeConversations, patients: $totalPatients, agents: $agentsOnline)';
}
