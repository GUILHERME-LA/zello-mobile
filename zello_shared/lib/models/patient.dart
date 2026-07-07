class Patient {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String cpf;
  final DateTime? birthDate;
  final DateTime? lastAccess;
  final int totalConversations;
  final String? professionalId;
  final String? city;
  final String? state;

  const Patient({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.cpf = '',
    this.birthDate,
    this.lastAccess,
    this.totalConversations = 0,
    this.professionalId,
    this.city,
    this.state,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      cpf: json['cpf'] as String? ?? '',
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'] as String)
          : null,
      lastAccess: json['lastAccess'] != null
          ? DateTime.tryParse(json['lastAccess'] as String)
          : null,
      totalConversations: (json['totalConversations'] as num?)?.toInt() ?? 0,
      professionalId: json['professionalId'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'cpf': cpf,
      'birthDate': birthDate?.toIso8601String(),
      'lastAccess': lastAccess?.toIso8601String(),
      'totalConversations': totalConversations,
      'professionalId': professionalId,
      'city': city,
      'state': state,
    };
  }

  Patient copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? cpf,
    DateTime? birthDate,
    DateTime? lastAccess,
    int? totalConversations,
    String? professionalId,
    String? city,
    String? state,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      cpf: cpf ?? this.cpf,
      birthDate: birthDate ?? this.birthDate,
      lastAccess: lastAccess ?? this.lastAccess,
      totalConversations: totalConversations ?? this.totalConversations,
      professionalId: professionalId ?? this.professionalId,
      city: city ?? this.city,
      state: state ?? this.state,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Patient && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Patient(id: $id, name: $name, phone: $phone, cpf: $cpf)';
}
