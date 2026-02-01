import 'package:equatable/equatable.dart';

/// Report type enum
enum ReportType {
  natal,
  weekly,
  monthly,
  yearly,
  love,
  career;

  static ReportType fromString(String value) {
    return ReportType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => ReportType.natal,
    );
  }
}

/// Report status enum
enum ReportStatus {
  pending,
  processing,
  completed,
  failed;

  static ReportStatus fromString(String value) {
    return ReportStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReportStatus.pending,
    );
  }
}

/// Report sections model
class ReportSections extends Equatable {
  final String? personality;
  final String? love;
  final String? career;
  final String? thisMonth;
  final String? thisWeek;
  final String? thisYear;

  const ReportSections({
    this.personality,
    this.love,
    this.career,
    this.thisMonth,
    this.thisWeek,
    this.thisYear,
  });

  factory ReportSections.fromJson(Map<String, dynamic> json) {
    return ReportSections(
      personality: json['personality'] as String?,
      love: json['love'] as String?,
      career: json['career'] as String?,
      thisMonth: json['this_month'] as String?,
      thisWeek: json['this_week'] as String?,
      thisYear: json['this_year'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'personality': personality,
      'love': love,
      'career': career,
      'this_month': thisMonth,
      'this_week': thisWeek,
      'this_year': thisYear,
    };
  }

  @override
  List<Object?> get props => [personality, love, career, thisMonth, thisWeek, thisYear];
}

/// Astro report model
class AstroReport extends Equatable {
  final String id;
  final String userId;
  final ReportType reportType;
  final Map<String, dynamic> chartJson;
  final String? reportText;
  final ReportSections sections;
  final ReportStatus status;
  final DateTime? validUntil;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AstroReport({
    required this.id,
    required this.userId,
    required this.reportType,
    this.chartJson = const {},
    this.reportText,
    this.sections = const ReportSections(),
    this.status = ReportStatus.pending,
    this.validUntil,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCompleted => status == ReportStatus.completed;
  bool get isValid =>
      validUntil == null || validUntil!.isAfter(DateTime.now());

  String? get sunSign => chartJson['sun'] as String?;
  String? get moonSign => chartJson['moon'] as String?;
  String? get ascendant => chartJson['ascendant'] as String?;

  factory AstroReport.fromJson(Map<String, dynamic> json) {
    final sectionsJson = json['sections'];

    return AstroReport(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      reportType: ReportType.fromString(json['report_type'] as String),
      chartJson: json['chart_json'] as Map<String, dynamic>? ?? {},
      reportText: json['report_text'] as String?,
      sections: sectionsJson != null && sectionsJson is Map
          ? ReportSections.fromJson(sectionsJson as Map<String, dynamic>)
          : const ReportSections(),
      status: ReportStatus.fromString(json['status'] as String? ?? 'pending'),
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'report_type': reportType.name,
      'chart_json': chartJson,
      'report_text': reportText,
      'sections': sections.toJson(),
      'status': status.name,
      'valid_until': validUntil?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        reportType,
        chartJson,
        reportText,
        sections,
        status,
        validUntil,
      ];
}
