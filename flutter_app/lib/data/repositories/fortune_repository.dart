import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/supabase_constants.dart';
import '../../core/errors/failures.dart';
import '../models/fortune_reading.dart';
import '../models/fortune_feedback.dart';
import '../services/storage_service.dart';
import '../services/functions_service.dart';

/// Fortune repository
class FortuneRepository {
  final SupabaseClient _client;
  final StorageService _storageService;
  final FunctionsService _functionsService;
  final _uuid = const Uuid();

  FortuneRepository(
    this._client,
    this._storageService,
    this._functionsService,
  );

  String? get _userId => _client.auth.currentUser?.id;

  /// Get all fortune readings for current user
  Future<List<FortuneReading>> getFortuneReadings({
    int limit = 20,
    int offset = 0,
  }) async {
    if (_userId == null) throw const AuthFailure('Not authenticated');

    try {
      final response = await _client
          .from(SupabaseConstants.fortuneReadingsTable)
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((j) => FortuneReading.fromJson(j as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerFailure('Failed to get fortune readings: ${e.message}');
    }
  }

  /// Get a single fortune reading by ID
  Future<FortuneReading?> getFortuneReading(String id) async {
    if (_userId == null) throw const AuthFailure('Not authenticated');

    try {
      final response = await _client
          .from(SupabaseConstants.fortuneReadingsTable)
          .select()
          .eq('id', id)
          .eq('user_id', _userId!)
          .maybeSingle();

      if (response == null) return null;
      return FortuneReading.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerFailure('Failed to get fortune reading: ${e.message}');
    }
  }

  /// Create a new fortune reading
  /// Uploads images and calls edge function
  Future<FortuneReading> createFortuneReading({
    required FortuneIntent intent,
    required File cupImage,
    File? saucerImage,
    String? customNote,
    String locale = 'tr',
  }) async {
    if (_userId == null) throw const AuthFailure('Not authenticated');

    final readingId = _uuid.v4();

    try {
      // Upload cup image
      final cupImagePath = await _storageService.uploadCupImage(
        userId: _userId!,
        imageFile: cupImage,
        readingId: readingId,
      );

      // Upload saucer image if provided
      String? saucerImagePath;
      if (saucerImage != null) {
        saucerImagePath = await _storageService.uploadSaucerImage(
          userId: _userId!,
          imageFile: saucerImage,
          readingId: readingId,
        );
      }

      // Get signed URLs
      final cupSignedUrl = await _storageService.getSignedUrl(cupImagePath);
      String? saucerSignedUrl;
      if (saucerImagePath != null) {
        saucerSignedUrl = await _storageService.getSignedUrl(saucerImagePath);
      }

      // Call edge function
      final result = await _functionsService.readFortune(
        intent: intent,
        cupImageSignedUrl: cupSignedUrl,
        saucerImageSignedUrl: saucerSignedUrl,
        locale: locale,
        customNote: customNote,
      );

      // Get the stored reading
      if (result.readingId != null) {
        final reading = await getFortuneReading(result.readingId!);
        if (reading != null) return reading;
      }

      // If we can't get from DB, construct from result
      final now = DateTime.now();
      return FortuneReading(
        id: result.readingId ?? readingId,
        userId: _userId!,
        intent: intent,
        cupImagePath: cupImagePath,
        saucerImagePath: saucerImagePath,
        resultText: result.resultText,
        symbols: result.symbols,
        timelines: result.timelines,
        status: FortuneStatus.completed,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      // Clean up uploaded images on failure
      try {
        await _storageService.deleteReadingImages(
          userId: _userId!,
          readingId: readingId,
        );
      } catch (_) {}
      rethrow;
    }
  }

  /// Delete a fortune reading
  Future<void> deleteFortuneReading(String id) async {
    if (_userId == null) throw const AuthFailure('Not authenticated');

    try {
      // Get reading to get image paths
      final reading = await getFortuneReading(id);
      if (reading == null) return;

      // Delete from database
      await _client
          .from(SupabaseConstants.fortuneReadingsTable)
          .delete()
          .eq('id', id)
          .eq('user_id', _userId!);

      // Delete images
      await _storageService.deleteReadingImages(
        userId: _userId!,
        readingId: id,
      );
    } on PostgrestException catch (e) {
      throw ServerFailure('Failed to delete fortune reading: ${e.message}');
    }
  }

  /// Get signed URL for cup image
  Future<String> getCupImageUrl(String path) async {
    return _storageService.getSignedUrl(path);
  }

  /// Submit feedback for a reading
  Future<FortuneFeedback> submitFeedback({
    required String readingId,
    required bool isAccurate,
    int? accuracyRating,
    String? note,
  }) async {
    if (_userId == null) throw const AuthFailure('Not authenticated');

    try {
      final response = await _client
          .from(SupabaseConstants.fortuneFeedbackTable)
          .insert({
            'reading_id': readingId,
            'user_id': _userId!,
            'is_accurate': isAccurate,
            'accuracy_rating': accuracyRating,
            'note': note,
          })
          .select()
          .single();

      return FortuneFeedback.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerFailure('Failed to submit feedback: ${e.message}');
    }
  }

  /// Get feedback for a reading
  Future<FortuneFeedback?> getFeedback(String readingId) async {
    if (_userId == null) throw const AuthFailure('Not authenticated');

    try {
      final response = await _client
          .from(SupabaseConstants.fortuneFeedbackTable)
          .select()
          .eq('reading_id', readingId)
          .eq('user_id', _userId!)
          .maybeSingle();

      if (response == null) return null;
      return FortuneFeedback.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerFailure('Failed to get feedback: ${e.message}');
    }
  }

  /// Get readings pending feedback (older than 7 days, no feedback yet)
  Future<List<FortuneReading>> getReadingsPendingFeedback() async {
    if (_userId == null) throw const AuthFailure('Not authenticated');

    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      // Get all completed readings older than 7 days
      final readings = await _client
          .from(SupabaseConstants.fortuneReadingsTable)
          .select()
          .eq('user_id', _userId!)
          .eq('status', 'completed')
          .lt('created_at', sevenDaysAgo.toIso8601String())
          .order('created_at', ascending: false)
          .limit(10);

      final readingsList = (readings as List)
          .map((j) => FortuneReading.fromJson(j as Map<String, dynamic>))
          .toList();

      // Filter out those with feedback
      final result = <FortuneReading>[];
      for (final reading in readingsList) {
        final feedback = await getFeedback(reading.id);
        if (feedback == null) {
          result.add(reading);
        }
      }

      return result;
    } on PostgrestException catch (e) {
      throw ServerFailure('Failed to get pending feedback: ${e.message}');
    }
  }
}
