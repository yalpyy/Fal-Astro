import 'package:equatable/equatable.dart';
import 'symbol.dart';

/// Fortune reading status
enum FortuneStatus {
  pending,
  processing,
  completed,
  failed;

  static FortuneStatus fromString(String value) {
    return FortuneStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FortuneStatus.pending,
    );
  }
}

/// Fortune intent
enum FortuneIntent {
  love,
  money,
  career,
  general;

  static FortuneIntent fromString(String value) {
    return FortuneIntent.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => FortuneIntent.general,
    );
  }
}

/// Fortune reading model
class FortuneReading extends Equatable {
  final String id;
  final String userId;
  final FortuneIntent intent;
  final String cupImagePath;
  final String? saucerImagePath;
  final String? resultText;
  final List<Symbol> symbols;
  final Timelines? timelines;
  final FortuneStatus status;
  final String? errorMessage;
  final int? processingTimeMs;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FortuneReading({
    required this.id,
    required this.userId,
    required this.intent,
    required this.cupImagePath,
    this.saucerImagePath,
    this.resultText,
    this.symbols = const [],
    this.timelines,
    this.status = FortuneStatus.pending,
    this.errorMessage,
    this.processingTimeMs,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCompleted => status == FortuneStatus.completed;
  bool get isFailed => status == FortuneStatus.failed;
  bool get isPending => status == FortuneStatus.pending;

  factory FortuneReading.fromJson(Map<String, dynamic> json) {
    final symbolsJson = json['symbols'];
    final timelinesJson = json['timelines'];

    return FortuneReading(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      intent: FortuneIntent.fromString(json['intent'] as String),
      cupImagePath: json['cup_image_path'] as String,
      saucerImagePath: json['saucer_image_path'] as String?,
      resultText: json['result_text'] as String?,
      symbols: symbolsJson != null && symbolsJson is List
          ? symbolsJson.map((s) => Symbol.fromJson(s as Map<String, dynamic>)).toList()
          : [],
      timelines: timelinesJson != null && timelinesJson is Map
          ? Timelines.fromJson(timelinesJson as Map<String, dynamic>)
          : null,
      status: FortuneStatus.fromString(json['status'] as String? ?? 'pending'),
      errorMessage: json['error_message'] as String?,
      processingTimeMs: json['processing_time_ms'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'intent': intent.name,
      'cup_image_path': cupImagePath,
      'saucer_image_path': saucerImagePath,
      'result_text': resultText,
      'symbols': symbols.map((s) => s.toJson()).toList(),
      'timelines': timelines?.toJson(),
      'status': status.name,
      'error_message': errorMessage,
      'processing_time_ms': processingTimeMs,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  FortuneReading copyWith({
    String? id,
    String? userId,
    FortuneIntent? intent,
    String? cupImagePath,
    String? saucerImagePath,
    String? resultText,
    List<Symbol>? symbols,
    Timelines? timelines,
    FortuneStatus? status,
    String? errorMessage,
    int? processingTimeMs,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FortuneReading(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      intent: intent ?? this.intent,
      cupImagePath: cupImagePath ?? this.cupImagePath,
      saucerImagePath: saucerImagePath ?? this.saucerImagePath,
      resultText: resultText ?? this.resultText,
      symbols: symbols ?? this.symbols,
      timelines: timelines ?? this.timelines,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        intent,
        cupImagePath,
        saucerImagePath,
        resultText,
        symbols,
        timelines,
        status,
      ];
}
