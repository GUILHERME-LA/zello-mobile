class Hospital {
  final String id;
  final String name;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final double distance;
  final String plan;
  final List<String> specialties;

  const Hospital({
    required this.id,
    required this.name,
    this.address = '',
    this.phone = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.distance = 0.0,
    this.plan = '',
    this.specialties = const [],
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      plan: json['plan'] as String? ?? '',
      specialties: (json['specialties'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'plan': plan,
      'specialties': specialties,
    };
  }

  Hospital copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    double? latitude,
    double? longitude,
    double? distance,
    String? plan,
    List<String>? specialties,
  }) {
    return Hospital(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
      plan: plan ?? this.plan,
      specialties: specialties ?? this.specialties,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Hospital && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Hospital(id: $id, name: $name, distance: ${distance.toStringAsFixed(1)}km)';
}
