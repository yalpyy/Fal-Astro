import 'package:equatable/equatable.dart';

/// Fortune feedback model
class FortuneFeedback extends Equatable {
  final String id;
  final String readingId;
  final String userId;
  final bool isAccurate;
  final int? accuracyRating;
  final String? note;
  final DateTime feedbackDate;
  final DateTime createdAt;

  const FortuneFeedback({
    required this.id,
    required this.readingId,
    required this.userId,
    required this.isAccurate,
    this.accuracyRating,
    this.note,
    required this.feedbackDate,
    required this.createdAt,
  });

  factory FortuneFeedback.fromJson(Map<String, dynamic> json) {
    return FortuneFeedback(
      id: json['id'] as String,
      readingId: json['reading_id'] as String,
      userId: json['user_id'] as String,
      isAccurate: json['is_accurate'] as bool,
      accuracyRating: json['accuracy_rating'] as int?,
      note: json['note'] as String?,
      feedbackDate: DateTime.parse(json['feedback_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reading_id': readingId,
      'user_id': userId,
      'is_accurate': isAccurate,
      'accuracy_rating': accuracyRating,
      'note': note,
      'feedback_date': feedbackDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// For insert
  Map<String, dynamic> toInsertJson() {
    return {
      'reading_id': readingId,
      'user_id': userId,
      'is_accurate': isAccurate,
      'accuracy_rating': accuracyRating,
      'note': note,
    };
  }

  @override
  List<Object?> get props => [
        id,
        readingId,
        userId,
        isAccurate,
        accuracyRating,
        note,
      ];
}
