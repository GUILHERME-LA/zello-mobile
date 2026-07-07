enum UserRole { admin, professional, patient }

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String token;
  final UserRole role;
  final String? profileId;
  final String? professionalId;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.token,
    this.role = UserRole.patient,
    this.profileId,
    this.professionalId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      token: json['token'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.patient,
      ),
      profileId: json['profile_id'] as String?,
      professionalId: json['professional_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'token': token,
      'role': role.name,
      'profile_id': profileId,
      'professional_id': professionalId,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? token,
    UserRole? role,
    String? profileId,
    String? professionalId,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      token: token ?? this.token,
      role: role ?? this.role,
      profileId: profileId ?? this.profileId,
      professionalId: professionalId ?? this.professionalId,
    );
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isProfessional => role == UserRole.professional;
  bool get isPatient => role == UserRole.patient;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User(id: $id, name: $name, email: $email, role: ${role.name})';
}
