/// Text and date formatters
class Formatters {
  Formatters._();

  /// Zodiac sign labels (Turkish)
  static const Map<String, String> zodiacLabelsTr = {
    'aries': 'Koç',
    'taurus': 'Boğa',
    'gemini': 'İkizler',
    'cancer': 'Yengeç',
    'leo': 'Aslan',
    'virgo': 'Başak',
    'libra': 'Terazi',
    'scorpio': 'Akrep',
    'sagittarius': 'Yay',
    'capricorn': 'Oğlak',
    'aquarius': 'Kova',
    'pisces': 'Balık',
  };

  /// Zodiac sign labels (English)
  static const Map<String, String> zodiacLabelsEn = {
    'aries': 'Aries',
    'taurus': 'Taurus',
    'gemini': 'Gemini',
    'cancer': 'Cancer',
    'leo': 'Leo',
    'virgo': 'Virgo',
    'libra': 'Libra',
    'scorpio': 'Scorpio',
    'sagittarius': 'Sagittarius',
    'capricorn': 'Capricorn',
    'aquarius': 'Aquarius',
    'pisces': 'Pisces',
  };

  /// Intent labels (Turkish)
  static const Map<String, String> intentLabelsTr = {
    'love': 'Aşk',
    'money': 'Para',
    'career': 'Kariyer',
    'general': 'Genel',
  };

  /// Intent labels (English)
  static const Map<String, String> intentLabelsEn = {
    'love': 'Love',
    'money': 'Money',
    'career': 'Career',
    'general': 'General',
  };

  /// Report type labels (Turkish)
  static const Map<String, String> reportTypeLabelsTr = {
    'natal': 'Doğum Haritası',
    'weekly': 'Haftalık',
    'monthly': 'Aylık',
    'yearly': 'Yıllık',
    'love': 'Aşk',
    'career': 'Kariyer',
  };

  /// Report type labels (English)
  static const Map<String, String> reportTypeLabelsEn = {
    'natal': 'Birth Chart',
    'weekly': 'Weekly',
    'monthly': 'Monthly',
    'yearly': 'Yearly',
    'love': 'Love',
    'career': 'Career',
  };

  /// Get zodiac label
  static String zodiacLabel(String sign, [String locale = 'tr']) {
    final labels = locale == 'tr' ? zodiacLabelsTr : zodiacLabelsEn;
    return labels[sign.toLowerCase()] ?? sign;
  }

  /// Get intent label
  static String intentLabel(String intent, [String locale = 'tr']) {
    final labels = locale == 'tr' ? intentLabelsTr : intentLabelsEn;
    return labels[intent.toLowerCase()] ?? intent;
  }

  /// Get report type label
  static String reportTypeLabel(String type, [String locale = 'tr']) {
    final labels = locale == 'tr' ? reportTypeLabelsTr : reportTypeLabelsEn;
    return labels[type.toLowerCase()] ?? type;
  }

  /// Format confidence score as percentage
  static String confidencePercent(double confidence) {
    return '${(confidence * 100).round()}%';
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
