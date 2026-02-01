import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/supabase_constants.dart';
import '../../core/errors/exceptions.dart';

/// Supabase Storage service for file uploads
class StorageService {
  final SupabaseClient _client;
  final _uuid = const Uuid();

  StorageService(this._client);

  /// Upload fortune cup image
  /// Returns the storage path
  Future<String> uploadCupImage({
    required String userId,
    required File imageFile,
    String? readingId,
  }) async {
    final id = readingId ?? _uuid.v4();
    final fileName = 'cup_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = '$userId/$id/$fileName';

    try {
      await _client.storage
          .from(SupabaseConstants.fortuneImagesBucket)
          .upload(path, imageFile);

      return path;
    } on StorageException catch (e) {
      throw StorageException('Failed to upload cup image: ${e.message}');
    }
  }

  /// Upload fortune saucer image
  Future<String> uploadSaucerImage({
    required String userId,
    required File imageFile,
    required String readingId,
  }) async {
    final fileName = 'saucer_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = '$userId/$readingId/$fileName';

    try {
      await _client.storage
          .from(SupabaseConstants.fortuneImagesBucket)
          .upload(path, imageFile);

      return path;
    } on StorageException catch (e) {
      throw StorageException('Failed to upload saucer image: ${e.message}');
    }
  }

  /// Get signed URL for an image
  Future<String> getSignedUrl(String path) async {
    try {
      final signedUrl = await _client.storage
          .from(SupabaseConstants.fortuneImagesBucket)
          .createSignedUrl(path, SupabaseConstants.signedUrlExpiry.inSeconds);

      return signedUrl;
    } on StorageException catch (e) {
      throw StorageException('Failed to get signed URL: ${e.message}');
    }
  }

  /// Delete an image
  Future<void> deleteImage(String path) async {
    try {
      await _client.storage
          .from(SupabaseConstants.fortuneImagesBucket)
          .remove([path]);
    } on StorageException catch (e) {
      throw StorageException('Failed to delete image: ${e.message}');
    }
  }

  /// Delete all images for a reading
  Future<void> deleteReadingImages({
    required String userId,
    required String readingId,
  }) async {
    try {
      final path = '$userId/$readingId';
      final files = await _client.storage
          .from(SupabaseConstants.fortuneImagesBucket)
          .list(path: path);

      if (files.isNotEmpty) {
        final paths = files.map((f) => '$path/${f.name}').toList();
        await _client.storage
            .from(SupabaseConstants.fortuneImagesBucket)
            .remove(paths);
      }
    } on StorageException catch (e) {
      throw StorageException('Failed to delete reading images: ${e.message}');
    }
  }
}
