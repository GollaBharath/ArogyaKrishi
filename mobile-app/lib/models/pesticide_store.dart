class PesticideStore {
  final String name;
  final String? address;
  final String? phone;
  final double latitude;
  final double longitude;
  final double? distanceKm;

  PesticideStore({
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
  });

  factory PesticideStore.fromJson(Map<String, dynamic> json) {
    return PesticideStore(
      name: json['name'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distanceKm: json['distance_km'] == null
          ? null
          : (json['distance_km'] as num).toDouble(),
    );
  }
}
