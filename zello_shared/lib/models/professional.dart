class Professional {
  final String id;
  final String profileId;
  final String name;
  final String type;
  final String specialty;
  final String council;
  final String councilUf;
  final String bio;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Professional({
    required this.id,
    required this.profileId,
    this.name = '',
    required this.type,
    this.specialty = '',
    this.council = '',
    this.councilUf = '',
    this.bio = '',
    this.createdAt,
    this.updatedAt,
  });

  factory Professional.fromJson(Map<String, dynamic> json) {
    final profiles = json['profiles'] as Map<String, dynamic>?;
    return Professional(
      id: json['id'] as String? ?? '',
      profileId: json['profile_id'] as String? ?? '',
      name: profiles?['name'] as String? ?? '',
      type: json['type'] as String? ?? 'medico',
      specialty: json['specialty'] as String? ?? '',
      council: json['council'] as String? ?? '',
      councilUf: json['council_uf'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'type': type,
      'specialty': specialty,
      'council': council,
      'council_uf': councilUf,
      'bio': bio,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Professional copyWith({
    String? id,
    String? profileId,
    String? name,
    String? type,
    String? specialty,
    String? council,
    String? councilUf,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Professional(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      type: type ?? this.type,
      specialty: specialty ?? this.specialty,
      council: council ?? this.council,
      councilUf: councilUf ?? this.councilUf,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Professional && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Professional(id: $id, type: $type, specialty: $specialty, council: $council)';
}
