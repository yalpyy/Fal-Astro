/// Form validators
class Validators {
  Validators._();

  /// Email validator
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi gerekli';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    return null;
  }

  /// Password validator
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }
    return null;
  }

  /// Required field validator
  static String? required(String? value, [String fieldName = 'Bu alan']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName gerekli';
    }
    return null;
  }

  /// Name validator
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'İsim gerekli';
    }
    if (value.length < 2) {
      return 'İsim en az 2 karakter olmalı';
    }
    return null;
  }

  /// Date validator
  static String? birthDate(DateTime? value) {
    if (value == null) {
      return 'Doğum tarihi gerekli';
    }
    final now = DateTime.now();
    if (value.isAfter(now)) {
      return 'Geçerli bir tarih seçin';
    }
    final age = now.year - value.year;
    if (age > 120) {
      return 'Geçerli bir tarih seçin';
    }
    return null;
  }

  /// City validator
  static String? city(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Şehir gerekli';
    }
    if (value.length < 2) {
      return 'Geçerli bir şehir girin';
    }
    return null;
  }

  /// Country validator
  static String? country(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ülke gerekli';
    }
    return null;
  }
}
