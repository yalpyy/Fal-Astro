import 'package:equatable/equatable.dart';

/// Base failure class
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];
}

/// Server/API related failures
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Sunucu hatası oluştu']) : super(message);
}

/// Network related failures
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'İnternet bağlantısı bulunamadı'])
      : super(message);
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure([String message = 'Kimlik doğrulama hatası']) : super(message);
}

/// Storage failures
class StorageFailure extends Failure {
  const StorageFailure([String message = 'Dosya yükleme hatası']) : super(message);
}

/// Cache failures
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Önbellek hatası']) : super(message);
}

/// Rate limit failures
class RateLimitFailure extends Failure {
  final int currentUsage;
  final int limit;
  final String tier;

  const RateLimitFailure({
    required this.currentUsage,
    required this.limit,
    required this.tier,
    String message = 'Günlük limit aşıldı',
  }) : super(message);

  @override
  List<Object?> get props => [message, currentUsage, limit, tier];
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Geçersiz veri']) : super(message);
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Veri bulunamadı']) : super(message);
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'İzin gerekli']) : super(message);
}
