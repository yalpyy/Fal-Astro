/**
 * Offline Astrology Calculator
 * Based on Jean Meeus's "Astronomical Algorithms"
 * No external API required
 */

export const ZODIAC_SIGNS = [
  'aries', 'taurus', 'gemini', 'cancer',
  'leo', 'virgo', 'libra', 'scorpio',
  'sagittarius', 'capricorn', 'aquarius', 'pisces'
] as const;

export const ZODIAC_SYMBOLS = ['♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓'];

export const ZODIAC_TR: Record<string, string> = {
  aries: 'Koç', taurus: 'Boğa', gemini: 'İkizler', cancer: 'Yengeç',
  leo: 'Aslan', virgo: 'Başak', libra: 'Terazi', scorpio: 'Akrep',
  sagittarius: 'Yay', capricorn: 'Oğlak', aquarius: 'Kova', pisces: 'Balık',
};

export type ZodiacSign = typeof ZODIAC_SIGNS[number];

// ============ UTILITY FUNCTIONS ============

/** Calculate Julian Day Number from date */
export function julianDay(date: Date): number {
  let y = date.getUTCFullYear();
  let m = date.getUTCMonth() + 1;
  const d = date.getUTCDate() +
    date.getUTCHours() / 24.0 +
    date.getUTCMinutes() / 1440.0 +
    date.getUTCSeconds() / 86400.0;

  if (m <= 2) {
    y -= 1;
    m += 12;
  }

  const a = Math.floor(y / 100);
  const b = 2 - a + Math.floor(a / 4);

  return Math.floor(365.25 * (y + 4716)) +
    Math.floor(30.6001 * (m + 1)) +
    d + b - 1524.5;
}

/** Calculate centuries since J2000.0 */
export function julianCenturies(date: Date): number {
  return (julianDay(date) - 2451545.0) / 36525.0;
}

/** Normalize angle to 0-360 degrees */
export function normalizeAngle(angle: number): number {
  angle = angle % 360;
  if (angle < 0) angle += 360;
  return angle;
}

/** Convert degrees to radians */
export function toRadians(degrees: number): number {
  return degrees * Math.PI / 180;
}

/** Convert radians to degrees */
export function toDegrees(radians: number): number {
  return radians * 180 / Math.PI;
}

/** Get zodiac sign index from ecliptic longitude (0-11) */
export function getZodiacIndex(longitude: number): number {
  return Math.floor(normalizeAngle(longitude) / 30);
}

/** Get zodiac sign name from longitude */
export function getZodiacSign(longitude: number): ZodiacSign {
  return ZODIAC_SIGNS[getZodiacIndex(longitude)];
}

/** Get degree within zodiac sign (0-30) */
export function getDegreeInSign(longitude: number): number {
  return normalizeAngle(longitude) % 30;
}

// ============ SUN POSITION ============

/** Calculate Sun's ecliptic longitude */
export function sunLongitude(date: Date): number {
  const t = julianCenturies(date);

  // Mean longitude of the Sun
  let l0 = normalizeAngle(280.46646 + 36000.76983 * t + 0.0003032 * t * t);

  // Mean anomaly of the Sun
  const m = normalizeAngle(357.52911 + 35999.05029 * t - 0.0001537 * t * t);
  const mRad = toRadians(m);

  // Equation of center
  const c = (1.914602 - 0.004817 * t - 0.000014 * t * t) * Math.sin(mRad) +
    (0.019993 - 0.000101 * t) * Math.sin(2 * mRad) +
    0.000289 * Math.sin(3 * mRad);

  // Sun's true longitude
  const sunLong = l0 + c;

  // Apparent longitude (corrected for nutation and aberration)
  const omega = 125.04 - 1934.136 * t;
  const apparent = sunLong - 0.00569 - 0.00478 * Math.sin(toRadians(omega));

  return normalizeAngle(apparent);
}

/** Get Sun sign for a date */
export function getSunSign(date: Date): ZodiacSign {
  return getZodiacSign(sunLongitude(date));
}

// ============ MOON POSITION ============

/** Calculate Moon's ecliptic longitude */
export function moonLongitude(date: Date): number {
  const t = julianCenturies(date);

  // Moon's mean longitude
  const lPrime = normalizeAngle(218.3164477 + 481267.88123421 * t - 0.0015786 * t * t);

  // Mean elongation of the Moon
  const d = normalizeAngle(297.8501921 + 445267.1114034 * t - 0.0018819 * t * t);

  // Sun's mean anomaly
  const m = normalizeAngle(357.5291092 + 35999.0502909 * t - 0.0001536 * t * t);

  // Moon's mean anomaly
  const mPrime = normalizeAngle(134.9633964 + 477198.8675055 * t + 0.0087414 * t * t);

  // Moon's argument of latitude
  const f = normalizeAngle(93.2720950 + 483202.0175233 * t - 0.0036539 * t * t);

  // Convert to radians
  const dRad = toRadians(d);
  const mRad = toRadians(m);
  const mPrimeRad = toRadians(mPrime);
  const fRad = toRadians(f);

  // Longitude correction (main terms)
  const longitude = lPrime +
    6.288774 * Math.sin(mPrimeRad) +
    1.274027 * Math.sin(2 * dRad - mPrimeRad) +
    0.658314 * Math.sin(2 * dRad) +
    0.213618 * Math.sin(2 * mPrimeRad) -
    0.185116 * Math.sin(mRad) -
    0.114332 * Math.sin(2 * fRad) +
    0.058793 * Math.sin(2 * dRad - 2 * mPrimeRad) +
    0.057066 * Math.sin(2 * dRad - mRad - mPrimeRad) +
    0.053322 * Math.sin(2 * dRad + mPrimeRad) +
    0.045758 * Math.sin(2 * dRad - mRad) -
    0.040923 * Math.sin(mRad - mPrimeRad) -
    0.034720 * Math.sin(dRad) -
    0.030383 * Math.sin(mRad + mPrimeRad) +
    0.015327 * Math.sin(2 * dRad - 2 * fRad) -
    0.012528 * Math.sin(mPrimeRad + 2 * fRad) +
    0.010980 * Math.sin(mPrimeRad - 2 * fRad);

  return normalizeAngle(longitude);
}

/** Get Moon sign for a date */
export function getMoonSign(date: Date): ZodiacSign {
  return getZodiacSign(moonLongitude(date));
}

/** Calculate Moon phase (0-1, where 0=new, 0.5=full) */
export function moonPhase(date: Date): number {
  const sunLong = sunLongitude(date);
  const moonLong = moonLongitude(date);
  return normalizeAngle(moonLong - sunLong) / 360;
}

/** Get Moon phase name */
export function getMoonPhaseName(date: Date, locale: 'tr' | 'en' = 'tr'): string {
  const phase = moonPhase(date);

  const phases = {
    tr: ['Yeni Ay', 'Hilal (Büyüyen)', 'İlk Dördün', 'Şişkin Ay (Büyüyen)',
         'Dolunay', 'Şişkin Ay (Küçülen)', 'Son Dördün', 'Hilal (Küçülen)'],
    en: ['New Moon', 'Waxing Crescent', 'First Quarter', 'Waxing Gibbous',
         'Full Moon', 'Waning Gibbous', 'Last Quarter', 'Waning Crescent']
  };

  if (phase < 0.0625) return phases[locale][0];
  if (phase < 0.1875) return phases[locale][1];
  if (phase < 0.3125) return phases[locale][2];
  if (phase < 0.4375) return phases[locale][3];
  if (phase < 0.5625) return phases[locale][4];
  if (phase < 0.6875) return phases[locale][5];
  if (phase < 0.8125) return phases[locale][6];
  if (phase < 0.9375) return phases[locale][7];
  return phases[locale][0];
}

// ============ PLANETARY POSITIONS ============

/** Helper function to calculate planet longitude */
function calculatePlanetLongitude(
  l: number, a: number, e: number, _i: number, _omega: number, pi: number, t: number
): number {
  const m = normalizeAngle(l - pi);
  const mRad = toRadians(m);

  // Equation of center (simplified)
  const c = toDegrees(
    (2 * e - e * e * e / 4) * Math.sin(mRad) +
    (5 * e * e / 4) * Math.sin(2 * mRad) +
    (13 * e * e * e / 12) * Math.sin(3 * mRad)
  );

  const trueLong = l + c;

  // Earth's position for geocentric conversion
  const earthL = normalizeAngle(100.4664 + 36000.7698 * t);
  const earthM = normalizeAngle(357.5291 + 35999.0503 * t);
  const earthMRad = toRadians(earthM);
  const earthC = 1.9146 * Math.sin(earthMRad) + 0.0200 * Math.sin(2 * earthMRad);
  const earthTrueLong = earthL + earthC;

  // Simplified geocentric longitude
  let geocentricLong: number;

  if (a < 1.0) {
    // Inner planets (Mercury, Venus)
    const elongation = trueLong - earthTrueLong;
    geocentricLong = earthTrueLong + elongation * 0.8;
  } else {
    // Outer planets
    geocentricLong = trueLong + (earthTrueLong - trueLong) * 0.1;
  }

  return normalizeAngle(geocentricLong);
}

/** Calculate Mercury's ecliptic longitude */
export function mercuryLongitude(date: Date): number {
  const t = julianCenturies(date);
  return calculatePlanetLongitude(
    normalizeAngle(252.2509 + 149474.0722 * t),
    0.38710,
    0.20563 - 0.000006 * t,
    7.0050 - 0.0018 * t,
    48.3309 + 1.1748 * t,
    77.4561 + 1.5564 * t,
    t
  );
}

/** Calculate Venus's ecliptic longitude */
export function venusLongitude(date: Date): number {
  const t = julianCenturies(date);
  return calculatePlanetLongitude(
    normalizeAngle(181.9798 + 58519.2130 * t),
    0.72333,
    0.00677 - 0.000005 * t,
    3.3947 + 0.0010 * t,
    76.6807 + 0.9011 * t,
    131.5637 + 1.4022 * t,
    t
  );
}

/** Calculate Mars's ecliptic longitude */
export function marsLongitude(date: Date): number {
  const t = julianCenturies(date);
  return calculatePlanetLongitude(
    normalizeAngle(355.4330 + 19141.6964 * t),
    1.52368,
    0.09340 + 0.000090 * t,
    1.8497 - 0.0007 * t,
    49.5581 + 0.7721 * t,
    336.0602 + 1.8410 * t,
    t
  );
}

/** Calculate Jupiter's ecliptic longitude */
export function jupiterLongitude(date: Date): number {
  const t = julianCenturies(date);
  return calculatePlanetLongitude(
    normalizeAngle(34.3515 + 3036.3027 * t),
    5.20260,
    0.04849 - 0.000132 * t,
    1.3033 - 0.0054 * t,
    100.4644 + 1.0207 * t,
    14.3312 + 1.6126 * t,
    t
  );
}

/** Calculate Saturn's ecliptic longitude */
export function saturnLongitude(date: Date): number {
  const t = julianCenturies(date);
  return calculatePlanetLongitude(
    normalizeAngle(50.0774 + 1223.5110 * t),
    9.55491,
    0.05551 - 0.000346 * t,
    2.4889 - 0.0037 * t,
    113.6655 + 0.8770 * t,
    93.0572 + 1.9637 * t,
    t
  );
}

// ============ ASCENDANT (RISING SIGN) ============

/**
 * Calculate Ascendant (Rising Sign)
 * Requires birth time and location
 */
export function calculateAscendant(
  birthDateTime: Date,
  latitude: number,
  longitude: number
): number {
  // Calculate Julian Day
  const jd = julianDay(birthDateTime);

  // Calculate Local Sidereal Time
  const t = (jd - 2451545.0) / 36525.0;

  // Greenwich Mean Sidereal Time at 0h UT
  const gmst0 = 100.46061837 +
    36000.770053608 * t +
    0.000387933 * t * t -
    t * t * t / 38710000;

  // Hours since midnight UT
  const ut = birthDateTime.getUTCHours() +
    birthDateTime.getUTCMinutes() / 60.0 +
    birthDateTime.getUTCSeconds() / 3600.0;

  // Greenwich Mean Sidereal Time
  const gmst = gmst0 + 360.98564736629 * ut / 24.0;

  // Local Sidereal Time
  const lst = normalizeAngle(gmst + longitude);

  // Obliquity of the ecliptic
  const eps = 23.4393 - 0.0000004 * t;
  const epsRad = toRadians(eps);

  // Calculate Ascendant
  const lstRad = toRadians(lst);
  const latRad = toRadians(latitude);

  const y = -Math.cos(lstRad);
  const x = Math.sin(lstRad) * Math.cos(epsRad) + Math.tan(latRad) * Math.sin(epsRad);

  const ascendant = toDegrees(Math.atan2(y, x));
  return normalizeAngle(ascendant);
}

/** Get Rising sign name */
export function getRisingSign(
  birthDateTime: Date,
  latitude: number,
  longitude: number
): ZodiacSign {
  const asc = calculateAscendant(birthDateTime, latitude, longitude);
  return getZodiacSign(asc);
}

// ============ COMPLETE CHART ============

export interface NatalChart {
  sun: { sign: ZodiacSign; degree: number; longitude: number };
  moon: { sign: ZodiacSign; degree: number; longitude: number };
  rising: { sign: ZodiacSign; degree: number; longitude: number } | null;
  mercury: { sign: ZodiacSign; degree: number; longitude: number };
  venus: { sign: ZodiacSign; degree: number; longitude: number };
  mars: { sign: ZodiacSign; degree: number; longitude: number };
  jupiter: { sign: ZodiacSign; degree: number; longitude: number };
  saturn: { sign: ZodiacSign; degree: number; longitude: number };
  moonPhase: string;
  moonPhaseValue: number;
}

/** Generate complete natal chart data */
export function calculateNatalChart(
  birthDateTime: Date,
  latitude?: number,
  longitude?: number,
  locale: 'tr' | 'en' = 'tr'
): NatalChart {
  const sunLong = sunLongitude(birthDateTime);
  const moonLong = moonLongitude(birthDateTime);
  const mercLong = mercuryLongitude(birthDateTime);
  const venLong = venusLongitude(birthDateTime);
  const marsLong = marsLongitude(birthDateTime);
  const jupLong = jupiterLongitude(birthDateTime);
  const satLong = saturnLongitude(birthDateTime);

  let rising: NatalChart['rising'] = null;
  if (latitude !== undefined && longitude !== undefined) {
    const ascLong = calculateAscendant(birthDateTime, latitude, longitude);
    rising = {
      sign: getZodiacSign(ascLong),
      degree: getDegreeInSign(ascLong),
      longitude: ascLong,
    };
  }

  return {
    sun: { sign: getZodiacSign(sunLong), degree: getDegreeInSign(sunLong), longitude: sunLong },
    moon: { sign: getZodiacSign(moonLong), degree: getDegreeInSign(moonLong), longitude: moonLong },
    rising,
    mercury: { sign: getZodiacSign(mercLong), degree: getDegreeInSign(mercLong), longitude: mercLong },
    venus: { sign: getZodiacSign(venLong), degree: getDegreeInSign(venLong), longitude: venLong },
    mars: { sign: getZodiacSign(marsLong), degree: getDegreeInSign(marsLong), longitude: marsLong },
    jupiter: { sign: getZodiacSign(jupLong), degree: getDegreeInSign(jupLong), longitude: jupLong },
    saturn: { sign: getZodiacSign(satLong), degree: getDegreeInSign(satLong), longitude: satLong },
    moonPhase: getMoonPhaseName(birthDateTime, locale),
    moonPhaseValue: moonPhase(birthDateTime),
  };
}

/** Get current planetary positions */
export function getCurrentPositions(locale: 'tr' | 'en' = 'tr'): NatalChart {
  return calculateNatalChart(new Date(), undefined, undefined, locale);
}

// ============ COMPATIBILITY ============

/** Element of a zodiac sign */
export function getElement(sign: ZodiacSign): 'fire' | 'earth' | 'air' | 'water' {
  const elements: Record<ZodiacSign, 'fire' | 'earth' | 'air' | 'water'> = {
    aries: 'fire', taurus: 'earth', gemini: 'air', cancer: 'water',
    leo: 'fire', virgo: 'earth', libra: 'air', scorpio: 'water',
    sagittarius: 'fire', capricorn: 'earth', aquarius: 'air', pisces: 'water',
  };
  return elements[sign];
}

/** Modality of a zodiac sign */
export function getModality(sign: ZodiacSign): 'cardinal' | 'fixed' | 'mutable' {
  const modalities: Record<ZodiacSign, 'cardinal' | 'fixed' | 'mutable'> = {
    aries: 'cardinal', taurus: 'fixed', gemini: 'mutable', cancer: 'cardinal',
    leo: 'fixed', virgo: 'mutable', libra: 'cardinal', scorpio: 'fixed',
    sagittarius: 'mutable', capricorn: 'cardinal', aquarius: 'fixed', pisces: 'mutable',
  };
  return modalities[sign];
}

/** Calculate compatibility score between two signs (0-100) */
export function calculateCompatibility(sign1: ZodiacSign, sign2: ZodiacSign): number {
  const index1 = ZODIAC_SIGNS.indexOf(sign1);
  const index2 = ZODIAC_SIGNS.indexOf(sign2);
  const diff = Math.abs(index1 - index2);
  const aspect = Math.min(diff, 12 - diff);

  // Aspect-based scoring
  const aspectScores: Record<number, number> = {
    0: 85,  // Conjunction (same sign)
    1: 50,  // Semi-sextile (adjacent)
    2: 75,  // Sextile (60°)
    3: 45,  // Square (90°) - challenging
    4: 90,  // Trine (120°) - harmonious
    5: 55,  // Quincunx (150°) - adjustment needed
    6: 70,  // Opposition (180°) - attraction/tension
  };

  let score = aspectScores[aspect] || 60;

  // Element compatibility bonus
  const elem1 = getElement(sign1);
  const elem2 = getElement(sign2);

  if (elem1 === elem2) {
    score += 10; // Same element
  } else if (
    (elem1 === 'fire' && elem2 === 'air') ||
    (elem1 === 'air' && elem2 === 'fire') ||
    (elem1 === 'earth' && elem2 === 'water') ||
    (elem1 === 'water' && elem2 === 'earth')
  ) {
    score += 5; // Compatible elements
  }

  return Math.min(100, Math.max(0, score));
}
