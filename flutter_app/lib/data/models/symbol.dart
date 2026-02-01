import 'package:equatable/equatable.dart';

/// Fortune symbol model
class Symbol extends Equatable {
  final String name;
  final String meaning;
  final double confidence;

  const Symbol({
    required this.name,
    required this.meaning,
    this.confidence = 0.7,
  });

  factory Symbol.fromJson(Map<String, dynamic> json) {
    return Symbol(
      name: json['name'] as String,
      meaning: json['meaning'] as String,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.7,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'meaning': meaning,
      'confidence': confidence,
    };
  }

  @override
  List<Object?> get props => [name, meaning, confidence];
}

/// Fortune timelines model
class Timelines extends Equatable {
  final String near; // 7 days
  final String mid;  // 1 month
  final String far;  // 3 months

  const Timelines({
    required this.near,
    required this.mid,
    required this.far,
  });

  factory Timelines.fromJson(Map<String, dynamic> json) {
    return Timelines(
      near: json['near'] as String? ?? '',
      mid: json['mid'] as String? ?? '',
      far: json['far'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'near': near,
      'mid': mid,
      'far': far,
    };
  }

  @override
  List<Object?> get props => [near, mid, far];
}
