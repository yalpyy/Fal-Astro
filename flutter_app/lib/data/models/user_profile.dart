import 'package:equatable/equatable.dart';

/// User profile model
class UserProfile extends Equatable {
  final String id;
  final String? name;
  final String? avatarUrl;
  final String locale;
  final DateTime createdAt;
  final DateTime updatedAt;

  // V2 Gamification fields
  final int credits;
  final int streakCount;
  final int longestStreak;
  final int totalReadings;
  final int level;
  final int experiencePoints;
  final DateTime? lastActiveDate;

  // V2 Legal fields
  final String? termsVersion;
  final DateTime? termsAcceptedAt;
  final String? privacyVersion;
  final DateTime? privacyAcceptedAt;
  final bool marketingConsent;

  // Admin
  final bool isAdmin;

  const UserProfile({
    required this.id,
    this.name,
    this.avatarUrl,
    this.locale = 'tr',
    required this.createdAt,
    required this.updatedAt,
    this.credits = 5,
    this.streakCount = 0,
    this.longestStreak = 0,
    this.totalReadings = 0,
    this.level = 1,
    this.experiencePoints = 0,
    this.lastActiveDate,
    this.termsVersion,
    this.termsAcceptedAt,
    this.privacyVersion,
    this.privacyAcceptedAt,
    this.marketingConsent = false,
    this.isAdmin = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      locale: json['locale'] as String? ?? 'tr',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      // V2 Gamification
      credits: json['credits'] as int? ?? 5,
      streakCount: json['streak_count'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      totalReadings: json['total_readings'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      experiencePoints: json['experience_points'] as int? ?? 0,
      lastActiveDate: json['last_active_date'] != null
          ? DateTime.tryParse(json['last_active_date'] as String)
          : null,
      // V2 Legal
      termsVersion: json['terms_version'] as String?,
      termsAcceptedAt: json['terms_accepted_at'] != null
          ? DateTime.tryParse(json['terms_accepted_at'] as String)
          : null,
      privacyVersion: json['privacy_version'] as String?,
      privacyAcceptedAt: json['privacy_accepted_at'] != null
          ? DateTime.tryParse(json['privacy_accepted_at'] as String)
          : null,
      marketingConsent: json['marketing_consent'] as bool? ?? false,
      isAdmin: json['is_admin'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar_url': avatarUrl,
      'locale': locale,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'credits': credits,
      'streak_count': streakCount,
      'longest_streak': longestStreak,
      'total_readings': totalReadings,
      'level': level,
      'experience_points': experiencePoints,
      'last_active_date': lastActiveDate?.toIso8601String(),
      'terms_version': termsVersion,
      'terms_accepted_at': termsAcceptedAt?.toIso8601String(),
      'privacy_version': privacyVersion,
      'privacy_accepted_at': privacyAcceptedAt?.toIso8601String(),
      'marketing_consent': marketingConsent,
      'is_admin': isAdmin,
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? locale,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? credits,
    int? streakCount,
    int? longestStreak,
    int? totalReadings,
    int? level,
    int? experiencePoints,
    DateTime? lastActiveDate,
    String? termsVersion,
    DateTime? termsAcceptedAt,
    String? privacyVersion,
    DateTime? privacyAcceptedAt,
    bool? marketingConsent,
    bool? isAdmin,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      locale: locale ?? this.locale,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      credits: credits ?? this.credits,
      streakCount: streakCount ?? this.streakCount,
      longestStreak: longestStreak ?? this.longestStreak,
      totalReadings: totalReadings ?? this.totalReadings,
      level: level ?? this.level,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      termsVersion: termsVersion ?? this.termsVersion,
      termsAcceptedAt: termsAcceptedAt ?? this.termsAcceptedAt,
      privacyVersion: privacyVersion ?? this.privacyVersion,
      privacyAcceptedAt: privacyAcceptedAt ?? this.privacyAcceptedAt,
      marketingConsent: marketingConsent ?? this.marketingConsent,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        avatarUrl,
        locale,
        createdAt,
        updatedAt,
        credits,
        streakCount,
        longestStreak,
        totalReadings,
        level,
        experiencePoints,
        lastActiveDate,
        termsVersion,
        termsAcceptedAt,
        privacyVersion,
        privacyAcceptedAt,
        marketingConsent,
        isAdmin,
      ];
}
