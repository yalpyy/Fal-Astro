import 'package:equatable/equatable.dart';
import '../../core/extensions/date_extensions.dart';

/// Birth profile model for astrology calculations
class BirthProfile extends Equatable {
  final String userId;
  final DateTime birthDate;
  final DateTime? birthTime;
  final String birthCity;
  final String birthCountry;
  final String timezone;
  final bool unknownTime;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BirthProfile({
    required this.userId,
    required this.birthDate,
    this.birthTime,
    required this.birthCity,
    required this.birthCountry,
    this.timezone = 'Europe/Istanbul',
    this.unknownTime = false,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get zodiac sign based on birth date
  String get zodiacSign => birthDate.zodiacSign;

  factory BirthProfile.fromJson(Map<String, dynamic> json) {
    return BirthProfile(
      userId: json['user_id'] as String,
      birthDate: DateTime.parse(json['birth_date'] as String),
      birthTime: json['birth_time'] != null
          ? _parseTimeOnly(json['birth_time'] as String)
          : null,
      birthCity: json['birth_city'] as String,
      birthCountry: json['birth_country'] as String,
      timezone: json['timezone'] as String? ?? 'Europe/Istanbul',
      unknownTime: json['unknown_time'] as bool? ?? false,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'birth_date': birthDate.toIso8601String().split('T').first,
      'birth_time': birthTime != null
          ? '${birthTime!.hour.toString().padLeft(2, '0')}:${birthTime!.minute.toString().padLeft(2, '0')}:00'
          : null,
      'birth_city': birthCity,
      'birth_country': birthCountry,
      'timezone': timezone,
      'unknown_time': unknownTime,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// For insert (without created_at/updated_at)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'birth_date': birthDate.toIso8601String().split('T').first,
      'birth_time': birthTime != null
          ? '${birthTime!.hour.toString().padLeft(2, '0')}:${birthTime!.minute.toString().padLeft(2, '0')}:00'
          : null,
      'birth_city': birthCity,
      'birth_country': birthCountry,
      'timezone': timezone,
      'unknown_time': unknownTime,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  BirthProfile copyWith({
    String? userId,
    DateTime? birthDate,
    DateTime? birthTime,
    String? birthCity,
    String? birthCountry,
    String? timezone,
    bool? unknownTime,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BirthProfile(
      userId: userId ?? this.userId,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      birthCity: birthCity ?? this.birthCity,
      birthCountry: birthCountry ?? this.birthCountry,
      timezone: timezone ?? this.timezone,
      unknownTime: unknownTime ?? this.unknownTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        birthDate,
        birthTime,
        birthCity,
        birthCountry,
        timezone,
        unknownTime,
        latitude,
        longitude,
      ];

  static DateTime? _parseTimeOnly(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day,
        int.parse(parts[0]), int.parse(parts[1]));
    } catch (_) {
      return null;
    }
  }
}
