import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../models/user_profile.dart';
import '../models/birth_profile.dart';

/// Profile repository
class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  /// Get user profile
  Future<UserProfile?> getProfile() async {
    if (_userId == null) return null;

    try {
      final response = await _client
          .from(SupabaseConstants.profilesTable)
          .select()
          .eq('id', _userId!)
          .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerFailure('Failed to get profile: ${e.message}');
    }
  }

  /// Update user profile
  Future<UserProfile> updateProfile({
    String? name,
    String? avatarUrl,
    String? locale,
  }) async {
    if (_userId == null) throw const AuthFailure('Not authenticated');

    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (locale != null) updates['locale'] = locale;

      final response = await _client
          .from(SupabaseConstants.profilesTable)
          .update(updates)
          .eq('id', _userId!)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerFailure('Failed to update profile: ${e.message}');
    }
  }

  /// Get birth profile
  Future<BirthProfile?> getBirthProfile() async {
    if (_userId == null) return null;

    try {
      final response = await _client
          .from(SupabaseConstants.birthProfilesTable)
          .select()
          .eq('user_id', _userId!)
          .maybeSingle();

      if (response == null) return null;
      return BirthProfile.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerFailure('Failed to get birth profile: ${e.message}');
    }
  }

  /// Check if birth profile exists
  Future<bool> hasBirthProfile() async {
    final profile = await getBirthProfile();
    return profile != null;
  }

  /// Create or update birth profile
  Future<BirthProfile> saveBirthProfile({
    required DateTime birthDate,
    DateTime? birthTime,
    required String birthCity,
    required String birthCountry,
    String timezone = 'Europe/Istanbul',
    bool unknownTime = false,
    double? latitude,
    double? longitude,
  }) async {
    if (_userId == null) throw const AuthFailure('Not authenticated');

    try {
      final data = {
        'user_id': _userId!,
        'birth_date': birthDate.toIso8601String().split('T').first,
        'birth_time': birthTime != null
            ? '${birthTime.hour.toString().padLeft(2, '0')}:${birthTime.minute.toString().padLeft(2, '0')}:00'
            : null,
        'birth_city': birthCity,
        'birth_country': birthCountry,
        'timezone': timezone,
        'unknown_time': unknownTime,
        'latitude': latitude,
        'longitude': longitude,
      };

      final response = await _client
          .from(SupabaseConstants.birthProfilesTable)
          .upsert(data)
          .select()
          .single();

      return BirthProfile.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerFailure('Failed to save birth profile: ${e.message}');
    }
  }

  /// Delete birth profile
  Future<void> deleteBirthProfile() async {
    if (_userId == null) throw const AuthFailure('Not authenticated');

    try {
      await _client
          .from(SupabaseConstants.birthProfilesTable)
          .delete()
          .eq('user_id', _userId!);
    } on PostgrestException catch (e) {
      throw ServerFailure('Failed to delete birth profile: ${e.message}');
    }
  }
}
