class UserLocation {
  final double latitude;
  final double longitude;
  final String city;
  final String country;
  final String timezone;
  
  UserLocation({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
    required this.timezone,
  });
  
  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      timezone: json['timezone'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'country': country,
      'timezone': timezone,
    };
  }
  
  @override
  String toString() {
    return '$city, $country';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserLocation &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.city == city &&
        other.country == country &&
        other.timezone == timezone;
  }
  
  @override
  int get hashCode {
    return latitude.hashCode ^
        longitude.hashCode ^
        city.hashCode ^
        country.hashCode ^
        timezone.hashCode;
  }
}

class QiblaDirection {
  final double direction;
  final double distance;
  final UserLocation userLocation;
  final DateTime calculatedAt;
  
  QiblaDirection({
    required this.direction,
    required this.distance,
    required this.userLocation,
    required this.calculatedAt,
  });
  
  factory QiblaDirection.fromJson(Map<String, dynamic> json) {
    return QiblaDirection(
      direction: json['direction']?.toDouble() ?? 0.0,
      distance: json['distance']?.toDouble() ?? 0.0,
      userLocation: UserLocation.fromJson(json['userLocation']),
      calculatedAt: DateTime.parse(json['calculatedAt']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'direction': direction,
      'distance': distance,
      'userLocation': userLocation.toJson(),
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }
  
  bool get isValid => direction >= 0 && direction <= 360;
  
  String get distanceInKm => '${(distance / 1000).toStringAsFixed(0)} km';
}