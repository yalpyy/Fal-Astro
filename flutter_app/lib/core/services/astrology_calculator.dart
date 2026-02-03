import 'dart:math';

/// Offline astrology calculator using astronomical algorithms
/// Based on Jean Meeus's "Astronomical Algorithms"
class AstrologyCalculator {
  static const List<String> zodiacSigns = [
    'aries', 'taurus', 'gemini', 'cancer',
    'leo', 'virgo', 'libra', 'scorpio',
    'sagittarius', 'capricorn', 'aquarius', 'pisces'
  ];

  static const List<String> zodiacSymbols = [
    '♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓'
  ];

  static const List<String> zodiacTurkish = [
    'Koç', 'Boğa', 'İkizler', 'Yengeç',
    'Aslan', 'Başak', 'Terazi', 'Akrep',
    'Yay', 'Oğlak', 'Kova', 'Balık'
  ];

  /// Calculate Julian Day Number from date
  static double julianDay(DateTime date) {
    int y = date.year;
    int m = date.month;
    double d = date.day +
        date.hour / 24.0 +
        date.minute / 1440.0 +
        date.second / 86400.0;

    if (m <= 2) {
      y -= 1;
      m += 12;
    }

    int a = (y / 100).floor();
    int b = 2 - a + (a / 4).floor();

    return (365.25 * (y + 4716)).floor() +
           (30.6001 * (m + 1)).floor() +
           d + b - 1524.5;
  }

  /// Calculate centuries since J2000.0
  static double julianCenturies(DateTime date) {
    return (julianDay(date) - 2451545.0) / 36525.0;
  }

  /// Normalize angle to 0-360 degrees
  static double normalizeAngle(double angle) {
    angle = angle % 360;
    if (angle < 0) angle += 360;
    return angle;
  }

  /// Convert degrees to radians
  static double toRadians(double degrees) => degrees * pi / 180;

  /// Convert radians to degrees
  static double toDegrees(double radians) => radians * 180 / pi;

  /// Get zodiac sign index from ecliptic longitude (0-11)
  static int getZodiacIndex(double longitude) {
    return (normalizeAngle(longitude) / 30).floor();
  }

  /// Get zodiac sign name from longitude
  static String getZodiacSign(double longitude) {
    return zodiacSigns[getZodiacIndex(longitude)];
  }

  /// Get degree within zodiac sign (0-30)
  static double getDegreeInSign(double longitude) {
    return normalizeAngle(longitude) % 30;
  }

  // ============ SUN POSITION ============

  /// Calculate Sun's ecliptic longitude
  static double sunLongitude(DateTime date) {
    double t = julianCenturies(date);

    // Mean longitude of the Sun
    double l0 = normalizeAngle(280.46646 + 36000.76983 * t + 0.0003032 * t * t);

    // Mean anomaly of the Sun
    double m = normalizeAngle(357.52911 + 35999.05029 * t - 0.0001537 * t * t);
    double mRad = toRadians(m);

    // Equation of center
    double c = (1.914602 - 0.004817 * t - 0.000014 * t * t) * sin(mRad) +
        (0.019993 - 0.000101 * t) * sin(2 * mRad) +
        0.000289 * sin(3 * mRad);

    // Sun's true longitude
    double sunLong = l0 + c;

    // Apparent longitude (corrected for nutation and aberration)
    double omega = 125.04 - 1934.136 * t;
    double apparent = sunLong - 0.00569 - 0.00478 * sin(toRadians(omega));

    return normalizeAngle(apparent);
  }

  /// Get Sun sign for a date
  static String getSunSign(DateTime date) {
    return getZodiacSign(sunLongitude(date));
  }

  // ============ MOON POSITION ============

  /// Calculate Moon's ecliptic longitude (simplified)
  static double moonLongitude(DateTime date) {
    double t = julianCenturies(date);

    // Moon's mean longitude
    double lPrime = normalizeAngle(
        218.3164477 + 481267.88123421 * t - 0.0015786 * t * t);

    // Mean elongation of the Moon
    double d = normalizeAngle(
        297.8501921 + 445267.1114034 * t - 0.0018819 * t * t);

    // Sun's mean anomaly
    double m = normalizeAngle(
        357.5291092 + 35999.0502909 * t - 0.0001536 * t * t);

    // Moon's mean anomaly
    double mPrime = normalizeAngle(
        134.9633964 + 477198.8675055 * t + 0.0087414 * t * t);

    // Moon's argument of latitude
    double f = normalizeAngle(
        93.2720950 + 483202.0175233 * t - 0.0036539 * t * t);

    // Convert to radians
    double dRad = toRadians(d);
    double mRad = toRadians(m);
    double mPrimeRad = toRadians(mPrime);
    double fRad = toRadians(f);

    // Longitude correction (main terms)
    double longitude = lPrime +
        6.288774 * sin(mPrimeRad) +
        1.274027 * sin(2 * dRad - mPrimeRad) +
        0.658314 * sin(2 * dRad) +
        0.213618 * sin(2 * mPrimeRad) -
        0.185116 * sin(mRad) -
        0.114332 * sin(2 * fRad) +
        0.058793 * sin(2 * dRad - 2 * mPrimeRad) +
        0.057066 * sin(2 * dRad - mRad - mPrimeRad) +
        0.053322 * sin(2 * dRad + mPrimeRad) +
        0.045758 * sin(2 * dRad - mRad) -
        0.040923 * sin(mRad - mPrimeRad) -
        0.034720 * sin(dRad) -
        0.030383 * sin(mRad + mPrimeRad) +
        0.015327 * sin(2 * dRad - 2 * fRad) -
        0.012528 * sin(mPrimeRad + 2 * fRad) +
        0.010980 * sin(mPrimeRad - 2 * fRad);

    return normalizeAngle(longitude);
  }

  /// Get Moon sign for a date
  static String getMoonSign(DateTime date) {
    return getZodiacSign(moonLongitude(date));
  }

  /// Calculate Moon phase (0-1, where 0=new, 0.5=full)
  static double moonPhase(DateTime date) {
    double sunLong = sunLongitude(date);
    double moonLong = moonLongitude(date);
    double phase = normalizeAngle(moonLong - sunLong) / 360;
    return phase;
  }

  /// Get Moon phase name
  static String getMoonPhaseName(DateTime date) {
    double phase = moonPhase(date);
    if (phase < 0.0625) return 'Yeni Ay';
    if (phase < 0.1875) return 'Hilal (Büyüyen)';
    if (phase < 0.3125) return 'İlk Dördün';
    if (phase < 0.4375) return 'Şişkin Ay (Büyüyen)';
    if (phase < 0.5625) return 'Dolunay';
    if (phase < 0.6875) return 'Şişkin Ay (Küçülen)';
    if (phase < 0.8125) return 'Son Dördün';
    if (phase < 0.9375) return 'Hilal (Küçülen)';
    return 'Yeni Ay';
  }

  // ============ PLANETARY POSITIONS ============

  /// Calculate Mercury's ecliptic longitude
  static double mercuryLongitude(DateTime date) {
    double t = julianCenturies(date);

    // Mercury orbital elements
    double l = normalizeAngle(252.2509 + 149474.0722 * t);
    double a = 0.38710;
    double e = 0.20563 - 0.000006 * t;
    double i = 7.0050 - 0.0018 * t;
    double omega = 48.3309 + 1.1748 * t;
    double pi = 77.4561 + 1.5564 * t;

    return _calculatePlanetLongitude(l, a, e, i, omega, pi, t);
  }

  /// Calculate Venus's ecliptic longitude
  static double venusLongitude(DateTime date) {
    double t = julianCenturies(date);

    double l = normalizeAngle(181.9798 + 58519.2130 * t);
    double a = 0.72333;
    double e = 0.00677 - 0.000005 * t;
    double i = 3.3947 + 0.0010 * t;
    double omega = 76.6807 + 0.9011 * t;
    double pi = 131.5637 + 1.4022 * t;

    return _calculatePlanetLongitude(l, a, e, i, omega, pi, t);
  }

  /// Calculate Mars's ecliptic longitude
  static double marsLongitude(DateTime date) {
    double t = julianCenturies(date);

    double l = normalizeAngle(355.4330 + 19141.6964 * t);
    double a = 1.52368;
    double e = 0.09340 + 0.000090 * t;
    double i = 1.8497 - 0.0007 * t;
    double omega = 49.5581 + 0.7721 * t;
    double pi = 336.0602 + 1.8410 * t;

    return _calculatePlanetLongitude(l, a, e, i, omega, pi, t);
  }

  /// Calculate Jupiter's ecliptic longitude
  static double jupiterLongitude(DateTime date) {
    double t = julianCenturies(date);

    double l = normalizeAngle(34.3515 + 3036.3027 * t);
    double a = 5.20260;
    double e = 0.04849 - 0.000132 * t;
    double i = 1.3033 - 0.0054 * t;
    double omega = 100.4644 + 1.0207 * t;
    double pi = 14.3312 + 1.6126 * t;

    return _calculatePlanetLongitude(l, a, e, i, omega, pi, t);
  }

  /// Calculate Saturn's ecliptic longitude
  static double saturnLongitude(DateTime date) {
    double t = julianCenturies(date);

    double l = normalizeAngle(50.0774 + 1223.5110 * t);
    double a = 9.55491;
    double e = 0.05551 - 0.000346 * t;
    double i = 2.4889 - 0.0037 * t;
    double omega = 113.6655 + 0.8770 * t;
    double pi = 93.0572 + 1.9637 * t;

    return _calculatePlanetLongitude(l, a, e, i, omega, pi, t);
  }

  /// Helper function to calculate heliocentric to geocentric longitude
  static double _calculatePlanetLongitude(
      double l, double a, double e, double i, double omega, double pi, double t) {
    // Simplified calculation - for more accuracy, use full VSOP87 theory
    double m = normalizeAngle(l - pi);
    double mRad = toRadians(m);

    // Equation of center (simplified)
    double c = (2 * e - e * e * e / 4) * sin(mRad) +
        (5 * e * e / 4) * sin(2 * mRad) +
        (13 * e * e * e / 12) * sin(3 * mRad);
    c = toDegrees(c);

    double trueLong = l + c;

    // Earth's position for geocentric conversion
    double earthL = normalizeAngle(100.4664 + 36000.7698 * t);
    double earthM = normalizeAngle(357.5291 + 35999.0503 * t);
    double earthMRad = toRadians(earthM);
    double earthC = 1.9146 * sin(earthMRad) + 0.0200 * sin(2 * earthMRad);
    double earthTrueLong = earthL + earthC;

    // Simplified geocentric longitude
    double geocentricLong = trueLong;

    // Apply correction based on planet's distance and Earth's position
    if (a < 1.0) {
      // Inner planets (Mercury, Venus)
      double elongation = trueLong - earthTrueLong;
      geocentricLong = earthTrueLong + elongation * 0.8;
    } else {
      // Outer planets
      geocentricLong = trueLong + (earthTrueLong - trueLong) * 0.1;
    }

    return normalizeAngle(geocentricLong);
  }

  // ============ ASCENDANT (RISING SIGN) ============

  /// Calculate Ascendant (Rising Sign)
  /// Requires birth time and location
  static double calculateAscendant(
      DateTime birthDateTime, double latitude, double longitude) {
    // Convert to UTC
    DateTime utc = birthDateTime.toUtc();

    // Calculate Julian Day
    double jd = julianDay(utc);

    // Calculate Local Sidereal Time
    double t = (jd - 2451545.0) / 36525.0;

    // Greenwich Mean Sidereal Time at 0h UT
    double gmst0 = 100.46061837 +
        36000.770053608 * t +
        0.000387933 * t * t -
        t * t * t / 38710000;

    // Hours since midnight UT
    double ut =
        utc.hour + utc.minute / 60.0 + utc.second / 3600.0;

    // Greenwich Mean Sidereal Time
    double gmst = gmst0 + 360.98564736629 * ut / 24.0;

    // Local Sidereal Time
    double lst = normalizeAngle(gmst + longitude);

    // Obliquity of the ecliptic
    double eps = 23.4393 - 0.0000004 * t;
    double epsRad = toRadians(eps);

    // Calculate Ascendant
    double lstRad = toRadians(lst);
    double latRad = toRadians(latitude);

    double y = -cos(lstRad);
    double x = sin(lstRad) * cos(epsRad) + tan(latRad) * sin(epsRad);

    double ascendant = toDegrees(atan2(y, x));
    return normalizeAngle(ascendant);
  }

  /// Get Rising sign name
  static String getRisingSign(
      DateTime birthDateTime, double latitude, double longitude) {
    double asc = calculateAscendant(birthDateTime, latitude, longitude);
    return getZodiacSign(asc);
  }

  // ============ COMPLETE CHART ============

  /// Generate complete natal chart data
  static NatalChart calculateNatalChart(
      DateTime birthDateTime, double latitude, double longitude) {
    return NatalChart(
      sunSign: getSunSign(birthDateTime),
      sunDegree: getDegreeInSign(sunLongitude(birthDateTime)),
      moonSign: getMoonSign(birthDateTime),
      moonDegree: getDegreeInSign(moonLongitude(birthDateTime)),
      risingSign: getRisingSign(birthDateTime, latitude, longitude),
      risingDegree: getDegreeInSign(
          calculateAscendant(birthDateTime, latitude, longitude)),
      mercurySign: getZodiacSign(mercuryLongitude(birthDateTime)),
      venusSign: getZodiacSign(venusLongitude(birthDateTime)),
      marsSign: getZodiacSign(marsLongitude(birthDateTime)),
      jupiterSign: getZodiacSign(jupiterLongitude(birthDateTime)),
      saturnSign: getZodiacSign(saturnLongitude(birthDateTime)),
      moonPhase: getMoonPhaseName(birthDateTime),
    );
  }

  /// Get current planetary positions
  static PlanetaryPositions getCurrentPositions() {
    final now = DateTime.now();
    return PlanetaryPositions(
      sun: PlanetPosition(
        sign: getSunSign(now),
        degree: getDegreeInSign(sunLongitude(now)),
        longitude: sunLongitude(now),
      ),
      moon: PlanetPosition(
        sign: getMoonSign(now),
        degree: getDegreeInSign(moonLongitude(now)),
        longitude: moonLongitude(now),
      ),
      mercury: PlanetPosition(
        sign: getZodiacSign(mercuryLongitude(now)),
        degree: getDegreeInSign(mercuryLongitude(now)),
        longitude: mercuryLongitude(now),
      ),
      venus: PlanetPosition(
        sign: getZodiacSign(venusLongitude(now)),
        degree: getDegreeInSign(venusLongitude(now)),
        longitude: venusLongitude(now),
      ),
      mars: PlanetPosition(
        sign: getZodiacSign(marsLongitude(now)),
        degree: getDegreeInSign(marsLongitude(now)),
        longitude: marsLongitude(now),
      ),
      jupiter: PlanetPosition(
        sign: getZodiacSign(jupiterLongitude(now)),
        degree: getDegreeInSign(jupiterLongitude(now)),
        longitude: jupiterLongitude(now),
      ),
      saturn: PlanetPosition(
        sign: getZodiacSign(saturnLongitude(now)),
        degree: getDegreeInSign(saturnLongitude(now)),
        longitude: saturnLongitude(now),
      ),
      moonPhase: getMoonPhaseName(now),
      moonPhaseValue: moonPhase(now),
    );
  }
}

/// Natal chart data model
class NatalChart {
  final String sunSign;
  final double sunDegree;
  final String moonSign;
  final double moonDegree;
  final String risingSign;
  final double risingDegree;
  final String mercurySign;
  final String venusSign;
  final String marsSign;
  final String jupiterSign;
  final String saturnSign;
  final String moonPhase;

  const NatalChart({
    required this.sunSign,
    required this.sunDegree,
    required this.moonSign,
    required this.moonDegree,
    required this.risingSign,
    required this.risingDegree,
    required this.mercurySign,
    required this.venusSign,
    required this.marsSign,
    required this.jupiterSign,
    required this.saturnSign,
    required this.moonPhase,
  });

  Map<String, dynamic> toJson() => {
        'sun': {'sign': sunSign, 'degree': sunDegree},
        'moon': {'sign': moonSign, 'degree': moonDegree},
        'rising': {'sign': risingSign, 'degree': risingDegree},
        'mercury': {'sign': mercurySign},
        'venus': {'sign': venusSign},
        'mars': {'sign': marsSign},
        'jupiter': {'sign': jupiterSign},
        'saturn': {'sign': saturnSign},
        'moonPhase': moonPhase,
      };
}

/// Planet position data model
class PlanetPosition {
  final String sign;
  final double degree;
  final double longitude;

  const PlanetPosition({
    required this.sign,
    required this.degree,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'sign': sign,
        'degree': degree,
        'longitude': longitude,
      };
}

/// Current planetary positions
class PlanetaryPositions {
  final PlanetPosition sun;
  final PlanetPosition moon;
  final PlanetPosition mercury;
  final PlanetPosition venus;
  final PlanetPosition mars;
  final PlanetPosition jupiter;
  final PlanetPosition saturn;
  final String moonPhase;
  final double moonPhaseValue;

  const PlanetaryPositions({
    required this.sun,
    required this.moon,
    required this.mercury,
    required this.venus,
    required this.mars,
    required this.jupiter,
    required this.saturn,
    required this.moonPhase,
    required this.moonPhaseValue,
  });

  Map<String, dynamic> toJson() => {
        'sun': sun.toJson(),
        'moon': moon.toJson(),
        'mercury': mercury.toJson(),
        'venus': venus.toJson(),
        'mars': mars.toJson(),
        'jupiter': jupiter.toJson(),
        'saturn': saturn.toJson(),
        'moonPhase': moonPhase,
        'moonPhaseValue': moonPhaseValue,
      };
}
