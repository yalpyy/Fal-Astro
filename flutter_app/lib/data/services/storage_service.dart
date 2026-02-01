import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/supabase_constants.dart';
import '../../core/errors/exceptions.dart';

/// Supabase Storage service for file uploads
class StorageService {
  final SupabaseClient _client;
  final _uuid = const Uuid();

  StorageService(this._client);

  /// Upload fortune cup image using XFile (cross-platform)
  /// Returns the storage path
  Future<String> uploadCupImage({
    required String userId,
    required XFile imageFile,
    String? readingId,
  }) async {
    final id = readingId ?? _uuid.v4();
    final fileName = 'cup_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = '$userId/$id/$fileName';

    try {
      final bytes = await imageFile.readAsBytes();
      await _client.storage
          .from(SupabaseConstants.fortuneImagesBucket)
          .uploadBinary(path, bytes, fileOptions: const FileOptions(
            contentType: 'image/jpeg',
          ));

      return path;
    } on StorageException catch (e) {
      throw AppStorageException('Failed to upload cup image: ${e.message}');
    }
  }

  /// Upload fortune saucer image using XFile (cross-platform)
  Future<String> uploadSaucerImage({
    required String userId,
    required XFile imageFile,
    required String readingId,
  }) async {
    final fileName = 'saucer_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = '$userId/$readingId/$fileName';

    try {
      final bytes = await imageFile.readAsBytes();
      await _client.storage
          .from(SupabaseConstants.fortuneImagesBucket)
          .uploadBinary(path, bytes, fileOptions: const FileOptions(
            contentType: 'image/jpeg',
          ));

      return path;
    } on StorageException catch (e) {
      throw AppStorageException('Failed to upload saucer image: ${e.message}');
    }
  }

  /// Upload image from bytes (useful for web)
  Future<String> uploadImageBytes({
    required String userId,
    required Uint8List bytes,
    required String readingId,
    required String type, // 'cup' or 'saucer'
  }) async {
    final fileName = '${type}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = '$userId/$readingId/$fileName';

    try {
      await _client.storage
          .from(SupabaseConstants.fortuneImagesBucket)
          .uploadBinary(path, bytes, fileOptions: const FileOptions(
            contentType: 'image/jpeg',
          ));

      return path;
    } on StorageException catch (e) {
      throw AppStorageException('Failed to upload $type image: ${e.message}');
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
      throw AppStorageException('Failed to get signed URL: ${e.message}');
    }
  }

  /// Delete an image
  Future<void> deleteImage(String path) async {
    try {
      await _client.storage
          .from(SupabaseConstants.fortuneImagesBucket)
          .remove([path]);
    } on StorageException catch (e) {
      throw AppStorageException('Failed to delete image: ${e.message}');
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
      throw AppStorageException('Failed to delete reading images: ${e.message}');
    }
  }
}
