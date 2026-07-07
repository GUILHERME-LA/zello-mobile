class Permission {
  final String id;
  final String professionalId;
  final String permission;
  final String? grantedBy;
  final DateTime? createdAt;

  const Permission({
    required this.id,
    required this.professionalId,
    required this.permission,
    this.grantedBy,
    this.createdAt,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'] as String? ?? '',
      professionalId: json['professional_id'] as String? ?? '',
      permission: json['permission'] as String? ?? '',
      grantedBy: json['granted_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professional_id': professionalId,
      'permission': permission,
      'granted_by': grantedBy,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Permission copyWith({
    String? id,
    String? professionalId,
    String? permission,
    String? grantedBy,
    DateTime? createdAt,
  }) {
    return Permission(
      id: id ?? this.id,
      professionalId: professionalId ?? this.professionalId,
      permission: permission ?? this.permission,
      grantedBy: grantedBy ?? this.grantedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Permission && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Permission(id: $id, permission: $permission)';
}
