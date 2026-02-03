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

  // ============ OUTER PLANETS (Uranus, Neptune, Pluto) ============

  /// Calculate Uranus's ecliptic longitude
  static double uranusLongitude(DateTime date) {
    double t = julianCenturies(date);

    double l = normalizeAngle(314.0550 + 429.8640 * t);
    double a = 19.21814;
    double e = 0.04638 - 0.000027 * t;
    double i = 0.7732 + 0.0001 * t;
    double omega = 74.0060 + 0.5211 * t;
    double pi = 173.0053 + 1.4863 * t;

    return _calculatePlanetLongitude(l, a, e, i, omega, pi, t);
  }

  /// Calculate Neptune's ecliptic longitude
  static double neptuneLongitude(DateTime date) {
    double t = julianCenturies(date);

    double l = normalizeAngle(304.3487 + 219.8833 * t);
    double a = 30.10957;
    double e = 0.00946 + 0.000003 * t;
    double i = 1.7700 - 0.0093 * t;
    double omega = 131.7841 + 1.1023 * t;
    double pi = 48.1228 + 1.4262 * t;

    return _calculatePlanetLongitude(l, a, e, i, omega, pi, t);
  }

  /// Calculate Pluto's ecliptic longitude (simplified)
  static double plutoLongitude(DateTime date) {
    double t = julianCenturies(date);

    // Pluto has a highly elliptical orbit, simplified calculation
    double l = normalizeAngle(238.9286 + 145.1781 * t);
    double a = 39.48168;
    double e = 0.24881 - 0.000005 * t;
    double i = 17.1417 + 0.0001 * t;
    double omega = 110.3034 + 1.3972 * t;
    double pi = 224.0675 + 1.3970 * t;

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

  // ============ HOUSE CALCULATIONS ============

  /// Calculate Midheaven (MC) - 10th house cusp
  static double calculateMidheaven(
      DateTime birthDateTime, double latitude, double longitude) {
    DateTime utc = birthDateTime.toUtc();
    double jd = julianDay(utc);
    double t = (jd - 2451545.0) / 36525.0;

    double gmst0 = 100.46061837 +
        36000.770053608 * t +
        0.000387933 * t * t -
        t * t * t / 38710000;

    double ut = utc.hour + utc.minute / 60.0 + utc.second / 3600.0;
    double gmst = gmst0 + 360.98564736629 * ut / 24.0;
    double lst = normalizeAngle(gmst + longitude);

    double eps = 23.4393 - 0.0000004 * t;
    double epsRad = toRadians(eps);
    double lstRad = toRadians(lst);

    double mc = toDegrees(atan2(sin(lstRad), cos(lstRad) * cos(epsRad)));
    return normalizeAngle(mc);
  }

  /// Calculate all 12 house cusps using Placidus system
  static List<double> calculateHouses(
      DateTime birthDateTime, double latitude, double longitude) {
    double asc = calculateAscendant(birthDateTime, latitude, longitude);
    double mc = calculateMidheaven(birthDateTime, latitude, longitude);

    List<double> houses = List.filled(12, 0.0);

    // House 1 (Ascendant)
    houses[0] = asc;

    // House 10 (Midheaven)
    houses[9] = mc;

    // House 4 (IC - opposite of MC)
    houses[3] = normalizeAngle(mc + 180);

    // House 7 (Descendant - opposite of Ascendant)
    houses[6] = normalizeAngle(asc + 180);

    // Intermediate houses using Placidus-style interpolation
    // Houses 2, 3 (between ASC and IC)
    double arc1 = normalizeAngle(houses[3] - asc);
    if (arc1 > 180) arc1 = 360 - arc1;
    houses[1] = normalizeAngle(asc + arc1 / 3);
    houses[2] = normalizeAngle(asc + 2 * arc1 / 3);

    // Houses 5, 6 (between IC and DESC)
    double arc2 = normalizeAngle(houses[6] - houses[3]);
    if (arc2 > 180) arc2 = 360 - arc2;
    houses[4] = normalizeAngle(houses[3] + arc2 / 3);
    houses[5] = normalizeAngle(houses[3] + 2 * arc2 / 3);

    // Houses 8, 9 (between DESC and MC)
    double arc3 = normalizeAngle(mc - houses[6]);
    if (arc3 > 180) arc3 = 360 - arc3;
    houses[7] = normalizeAngle(houses[6] + arc3 / 3);
    houses[8] = normalizeAngle(houses[6] + 2 * arc3 / 3);

    // Houses 11, 12 (between MC and ASC)
    double arc4 = normalizeAngle(asc + 360 - mc);
    if (arc4 > 180) arc4 = 360 - arc4;
    houses[10] = normalizeAngle(mc + arc4 / 3);
    houses[11] = normalizeAngle(mc + 2 * arc4 / 3);

    return houses;
  }

  /// Get house position for a planet
  static int getHousePosition(double planetLongitude, List<double> houses) {
    for (int i = 0; i < 12; i++) {
      int nextHouse = (i + 1) % 12;
      double start = houses[i];
      double end = houses[nextHouse];

      if (end < start) end += 360;
      double planet = planetLongitude;
      if (planet < start) planet += 360;

      if (planet >= start && planet < end) {
        return i + 1;
      }
    }
    return 1;
  }

  /// House names in Turkish
  static const List<String> houseNames = [
    'Benlik Evi',           // 1st - Self
    'Değerler Evi',         // 2nd - Values, Money
    'İletişim Evi',         // 3rd - Communication
    'Aile Evi',             // 4th - Home, Family
    'Yaratıcılık Evi',      // 5th - Creativity, Romance
    'Sağlık Evi',           // 6th - Health, Work
    'İlişkiler Evi',        // 7th - Partnerships
    'Dönüşüm Evi',          // 8th - Transformation
    'Felsefe Evi',          // 9th - Philosophy, Travel
    'Kariyer Evi',          // 10th - Career
    'Dostluk Evi',          // 11th - Friends, Goals
    'Bilinçaltı Evi',       // 12th - Subconscious
  ];

  // ============ ASPECT CALCULATIONS ============

  /// Major aspects with their orbs
  static const Map<String, Map<String, dynamic>> aspects = {
    'conjunction': {'angle': 0, 'orb': 8, 'symbol': '☌', 'nature': 'major'},
    'sextile': {'angle': 60, 'orb': 6, 'symbol': '⚹', 'nature': 'harmonious'},
    'square': {'angle': 90, 'orb': 8, 'symbol': '□', 'nature': 'challenging'},
    'trine': {'angle': 120, 'orb': 8, 'symbol': '△', 'nature': 'harmonious'},
    'opposition': {'angle': 180, 'orb': 8, 'symbol': '☍', 'nature': 'challenging'},
    'quincunx': {'angle': 150, 'orb': 3, 'symbol': '⚻', 'nature': 'minor'},
    'semisextile': {'angle': 30, 'orb': 2, 'symbol': '⚺', 'nature': 'minor'},
    'semisquare': {'angle': 45, 'orb': 2, 'symbol': '∠', 'nature': 'minor'},
    'sesquiquadrate': {'angle': 135, 'orb': 2, 'symbol': '⚼', 'nature': 'minor'},
  };

  /// Calculate aspect between two planets
  static Aspect? calculateAspect(
      double planet1Longitude, double planet2Longitude,
      String planet1Name, String planet2Name) {
    double diff = (planet1Longitude - planet2Longitude).abs();
    if (diff > 180) diff = 360 - diff;

    for (var entry in aspects.entries) {
      double aspectAngle = entry.value['angle'].toDouble();
      double orb = entry.value['orb'].toDouble();

      double actualOrb = (diff - aspectAngle).abs();
      if (actualOrb <= orb) {
        return Aspect(
          planet1: planet1Name,
          planet2: planet2Name,
          aspectType: entry.key,
          angle: aspectAngle,
          actualAngle: diff,
          orb: actualOrb,
          symbol: entry.value['symbol'],
          nature: entry.value['nature'],
          isApplying: planet1Longitude < planet2Longitude,
        );
      }
    }
    return null;
  }

  /// Calculate all aspects in a chart
  static List<Aspect> calculateAllAspects(Map<String, double> planetPositions) {
    List<Aspect> aspectList = [];
    List<String> planets = planetPositions.keys.toList();

    for (int i = 0; i < planets.length; i++) {
      for (int j = i + 1; j < planets.length; j++) {
        Aspect? aspect = calculateAspect(
          planetPositions[planets[i]]!,
          planetPositions[planets[j]]!,
          planets[i],
          planets[j],
        );
        if (aspect != null) {
          aspectList.add(aspect);
        }
      }
    }

    return aspectList;
  }

  /// Get dominant element in chart
  static String getDominantElement(Map<String, String> planetSigns) {
    Map<String, int> elementCounts = {'fire': 0, 'earth': 0, 'air': 0, 'water': 0};

    final elements = {
      'aries': 'fire', 'leo': 'fire', 'sagittarius': 'fire',
      'taurus': 'earth', 'virgo': 'earth', 'capricorn': 'earth',
      'gemini': 'air', 'libra': 'air', 'aquarius': 'air',
      'cancer': 'water', 'scorpio': 'water', 'pisces': 'water',
    };

    for (var sign in planetSigns.values) {
      String? element = elements[sign.toLowerCase()];
      if (element != null) {
        elementCounts[element] = elementCounts[element]! + 1;
      }
    }

    return elementCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get dominant modality in chart
  static String getDominantModality(Map<String, String> planetSigns) {
    Map<String, int> modalityCounts = {'cardinal': 0, 'fixed': 0, 'mutable': 0};

    final modalities = {
      'aries': 'cardinal', 'cancer': 'cardinal', 'libra': 'cardinal', 'capricorn': 'cardinal',
      'taurus': 'fixed', 'leo': 'fixed', 'scorpio': 'fixed', 'aquarius': 'fixed',
      'gemini': 'mutable', 'virgo': 'mutable', 'sagittarius': 'mutable', 'pisces': 'mutable',
    };

    for (var sign in planetSigns.values) {
      String? modality = modalities[sign.toLowerCase()];
      if (modality != null) {
        modalityCounts[modality] = modalityCounts[modality]! + 1;
      }
    }

    return modalityCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // ============ COMPLETE CHART ============

  /// Generate complete natal chart data
  static NatalChart calculateNatalChart(
      DateTime birthDateTime, double latitude, double longitude) {
    // Calculate all planet longitudes
    final sunLong = sunLongitude(birthDateTime);
    final moonLong = moonLongitude(birthDateTime);
    final mercuryLong = mercuryLongitude(birthDateTime);
    final venusLong = venusLongitude(birthDateTime);
    final marsLong = marsLongitude(birthDateTime);
    final jupiterLong = jupiterLongitude(birthDateTime);
    final saturnLong = saturnLongitude(birthDateTime);
    final uranusLong = uranusLongitude(birthDateTime);
    final neptuneLong = neptuneLongitude(birthDateTime);
    final plutoLong = plutoLongitude(birthDateTime);
    final ascLong = calculateAscendant(birthDateTime, latitude, longitude);
    final mcLong = calculateMidheaven(birthDateTime, latitude, longitude);

    // Calculate houses
    final houses = calculateHouses(birthDateTime, latitude, longitude);

    // Prepare planet positions map for aspects
    final planetPositions = {
      'Sun': sunLong,
      'Moon': moonLong,
      'Mercury': mercuryLong,
      'Venus': venusLong,
      'Mars': marsLong,
      'Jupiter': jupiterLong,
      'Saturn': saturnLong,
      'Uranus': uranusLong,
      'Neptune': neptuneLong,
      'Pluto': plutoLong,
    };

    // Calculate all aspects
    final chartAspects = calculateAllAspects(planetPositions);

    // Get dominant element and modality
    final planetSigns = {
      'Sun': getZodiacSign(sunLong),
      'Moon': getZodiacSign(moonLong),
      'Mercury': getZodiacSign(mercuryLong),
      'Venus': getZodiacSign(venusLong),
      'Mars': getZodiacSign(marsLong),
      'Jupiter': getZodiacSign(jupiterLong),
      'Saturn': getZodiacSign(saturnLong),
    };

    return NatalChart(
      sunSign: getZodiacSign(sunLong),
      sunDegree: getDegreeInSign(sunLong),
      moonSign: getZodiacSign(moonLong),
      moonDegree: getDegreeInSign(moonLong),
      risingSign: getZodiacSign(ascLong),
      risingDegree: getDegreeInSign(ascLong),
      midheavenSign: getZodiacSign(mcLong),
      midheavenDegree: getDegreeInSign(mcLong),
      mercurySign: getZodiacSign(mercuryLong),
      mercuryDegree: getDegreeInSign(mercuryLong),
      venusSign: getZodiacSign(venusLong),
      venusDegree: getDegreeInSign(venusLong),
      marsSign: getZodiacSign(marsLong),
      marsDegree: getDegreeInSign(marsLong),
      jupiterSign: getZodiacSign(jupiterLong),
      jupiterDegree: getDegreeInSign(jupiterLong),
      saturnSign: getZodiacSign(saturnLong),
      saturnDegree: getDegreeInSign(saturnLong),
      uranusSign: getZodiacSign(uranusLong),
      uranusDegree: getDegreeInSign(uranusLong),
      neptuneSign: getZodiacSign(neptuneLong),
      neptuneDegree: getDegreeInSign(neptuneLong),
      plutoSign: getZodiacSign(plutoLong),
      plutoDegree: getDegreeInSign(plutoLong),
      moonPhase: getMoonPhaseName(birthDateTime),
      houses: houses,
      aspects: chartAspects,
      dominantElement: getDominantElement(planetSigns),
      dominantModality: getDominantModality(planetSigns),
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
      uranus: PlanetPosition(
        sign: getZodiacSign(uranusLongitude(now)),
        degree: getDegreeInSign(uranusLongitude(now)),
        longitude: uranusLongitude(now),
      ),
      neptune: PlanetPosition(
        sign: getZodiacSign(neptuneLongitude(now)),
        degree: getDegreeInSign(neptuneLongitude(now)),
        longitude: neptuneLongitude(now),
      ),
      pluto: PlanetPosition(
        sign: getZodiacSign(plutoLongitude(now)),
        degree: getDegreeInSign(plutoLongitude(now)),
        longitude: plutoLongitude(now),
      ),
      moonPhase: getMoonPhaseName(now),
      moonPhaseValue: moonPhase(now),
    );
  }
}

/// Natal chart data model with all planets and houses
class NatalChart {
  // Main luminaries
  final String sunSign;
  final double sunDegree;
  final String moonSign;
  final double moonDegree;

  // Angles
  final String risingSign;
  final double risingDegree;
  final String midheavenSign;
  final double midheavenDegree;

  // Personal planets
  final String mercurySign;
  final double mercuryDegree;
  final String venusSign;
  final double venusDegree;
  final String marsSign;
  final double marsDegree;

  // Social planets
  final String jupiterSign;
  final double jupiterDegree;
  final String saturnSign;
  final double saturnDegree;

  // Outer planets
  final String uranusSign;
  final double uranusDegree;
  final String neptuneSign;
  final double neptuneDegree;
  final String plutoSign;
  final double plutoDegree;

  // Additional data
  final String moonPhase;
  final List<double> houses;
  final List<Aspect> aspects;
  final String dominantElement;
  final String dominantModality;

  const NatalChart({
    required this.sunSign,
    required this.sunDegree,
    required this.moonSign,
    required this.moonDegree,
    required this.risingSign,
    required this.risingDegree,
    required this.midheavenSign,
    required this.midheavenDegree,
    required this.mercurySign,
    required this.mercuryDegree,
    required this.venusSign,
    required this.venusDegree,
    required this.marsSign,
    required this.marsDegree,
    required this.jupiterSign,
    required this.jupiterDegree,
    required this.saturnSign,
    required this.saturnDegree,
    required this.uranusSign,
    required this.uranusDegree,
    required this.neptuneSign,
    required this.neptuneDegree,
    required this.plutoSign,
    required this.plutoDegree,
    required this.moonPhase,
    required this.houses,
    required this.aspects,
    required this.dominantElement,
    required this.dominantModality,
  });

  Map<String, dynamic> toJson() => {
        'sun': {'sign': sunSign, 'degree': sunDegree},
        'moon': {'sign': moonSign, 'degree': moonDegree},
        'rising': {'sign': risingSign, 'degree': risingDegree},
        'midheaven': {'sign': midheavenSign, 'degree': midheavenDegree},
        'mercury': {'sign': mercurySign, 'degree': mercuryDegree},
        'venus': {'sign': venusSign, 'degree': venusDegree},
        'mars': {'sign': marsSign, 'degree': marsDegree},
        'jupiter': {'sign': jupiterSign, 'degree': jupiterDegree},
        'saturn': {'sign': saturnSign, 'degree': saturnDegree},
        'uranus': {'sign': uranusSign, 'degree': uranusDegree},
        'neptune': {'sign': neptuneSign, 'degree': neptuneDegree},
        'pluto': {'sign': plutoSign, 'degree': plutoDegree},
        'moonPhase': moonPhase,
        'houses': houses,
        'aspects': aspects.map((a) => a.toJson()).toList(),
        'dominantElement': dominantElement,
        'dominantModality': dominantModality,
      };

  /// Get planet position description in Turkish
  String getPlanetDescription(String planet) {
    final signsTr = AstrologyCalculator.zodiacTurkish;
    final signs = AstrologyCalculator.zodiacSigns;

    String getSignTr(String sign) {
      int idx = signs.indexOf(sign.toLowerCase());
      return idx >= 0 ? signsTr[idx] : sign;
    }

    switch (planet.toLowerCase()) {
      case 'sun':
      case 'güneş':
        return '${getSignTr(sunSign)} ${sunDegree.toStringAsFixed(1)}°';
      case 'moon':
      case 'ay':
        return '${getSignTr(moonSign)} ${moonDegree.toStringAsFixed(1)}°';
      case 'rising':
      case 'yükselen':
        return '${getSignTr(risingSign)} ${risingDegree.toStringAsFixed(1)}°';
      case 'mercury':
      case 'merkür':
        return '${getSignTr(mercurySign)} ${mercuryDegree.toStringAsFixed(1)}°';
      case 'venus':
      case 'venüs':
        return '${getSignTr(venusSign)} ${venusDegree.toStringAsFixed(1)}°';
      case 'mars':
        return '${getSignTr(marsSign)} ${marsDegree.toStringAsFixed(1)}°';
      case 'jupiter':
      case 'jüpiter':
        return '${getSignTr(jupiterSign)} ${jupiterDegree.toStringAsFixed(1)}°';
      case 'saturn':
      case 'satürn':
        return '${getSignTr(saturnSign)} ${saturnDegree.toStringAsFixed(1)}°';
      case 'uranus':
      case 'uranüs':
        return '${getSignTr(uranusSign)} ${uranusDegree.toStringAsFixed(1)}°';
      case 'neptune':
      case 'neptün':
        return '${getSignTr(neptuneSign)} ${neptuneDegree.toStringAsFixed(1)}°';
      case 'pluto':
      case 'plüton':
        return '${getSignTr(plutoSign)} ${plutoDegree.toStringAsFixed(1)}°';
      default:
        return '';
    }
  }
}

/// Aspect between two planets
class Aspect {
  final String planet1;
  final String planet2;
  final String aspectType;
  final double angle;
  final double actualAngle;
  final double orb;
  final String symbol;
  final String nature;
  final bool isApplying;

  const Aspect({
    required this.planet1,
    required this.planet2,
    required this.aspectType,
    required this.angle,
    required this.actualAngle,
    required this.orb,
    required this.symbol,
    required this.nature,
    required this.isApplying,
  });

  Map<String, dynamic> toJson() => {
        'planet1': planet1,
        'planet2': planet2,
        'type': aspectType,
        'angle': angle,
        'actualAngle': actualAngle,
        'orb': orb,
        'symbol': symbol,
        'nature': nature,
        'isApplying': isApplying,
      };

  /// Get Turkish name of aspect
  String get nameTr {
    switch (aspectType) {
      case 'conjunction':
        return 'Kavuşum';
      case 'sextile':
        return 'Altmışlık';
      case 'square':
        return 'Kare';
      case 'trine':
        return 'Üçgen';
      case 'opposition':
        return 'Karşıt';
      case 'quincunx':
        return 'Quincunx';
      case 'semisextile':
        return 'Yarı Altmışlık';
      case 'semisquare':
        return 'Yarı Kare';
      case 'sesquiquadrate':
        return 'Sesquikare';
      default:
        return aspectType;
    }
  }

  /// Check if this is a harmonious aspect
  bool get isHarmonious => nature == 'harmonious';

  /// Check if this is a challenging aspect
  bool get isChallenging => nature == 'challenging';

  @override
  String toString() => '$planet1 $symbol $planet2 (${orb.toStringAsFixed(1)}°)';
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
  final PlanetPosition uranus;
  final PlanetPosition neptune;
  final PlanetPosition pluto;
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
    required this.uranus,
    required this.neptune,
    required this.pluto,
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
        'uranus': uranus.toJson(),
        'neptune': neptune.toJson(),
        'pluto': pluto.toJson(),
        'moonPhase': moonPhase,
        'moonPhaseValue': moonPhaseValue,
      };
}
