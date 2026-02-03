/**
 * Daily Horoscope Generator
 * Generates horoscopes based on actual planetary positions
 * No external API required
 */

import {
  getCurrentPositions,
  ZODIAC_SIGNS,
  ZODIAC_TR,
  ZodiacSign,
  PlanetaryPositions,
} from './astrology_calculator.ts';

export interface DailyHoroscope {
  sign: ZodiacSign;
  signTr: string;
  date: string;
  general: string;
  love: string;
  career: string;
  health: string;
  scores: {
    overall: number;
    love: number;
    career: number;
    health: number;
  };
  luckyNumbers: number[];
  luckyColor: string;
  moonPhase: string;
  planetaryInfluence: string;
}

// Seeded random for reproducible daily results
function seededRandom(seed: number): () => number {
  return function() {
    seed = (seed * 9301 + 49297) % 233280;
    return seed / 233280;
  };
}

function getDateSeed(date: Date, signIndex: number): number {
  return date.getFullYear() * 10000 + (date.getMonth() + 1) * 100 + date.getDate() + signIndex * 7;
}

/** Calculate aspect between two signs (0-6) */
function calculateAspect(sign1Index: number, sign2Index: number): number {
  const diff = Math.abs(sign1Index - sign2Index);
  return diff > 6 ? 12 - diff : diff;
}

/** Get element of a sign */
function getElement(sign: ZodiacSign): 'fire' | 'earth' | 'air' | 'water' {
  const elements: Record<ZodiacSign, 'fire' | 'earth' | 'air' | 'water'> = {
    aries: 'fire', leo: 'fire', sagittarius: 'fire',
    taurus: 'earth', virgo: 'earth', capricorn: 'earth',
    gemini: 'air', libra: 'air', aquarius: 'air',
    cancer: 'water', scorpio: 'water', pisces: 'water',
  };
  return elements[sign];
}

function areCompatibleElements(e1: string, e2: string): boolean {
  return (e1 === 'fire' && e2 === 'air') ||
         (e1 === 'air' && e2 === 'fire') ||
         (e1 === 'earth' && e2 === 'water') ||
         (e1 === 'water' && e2 === 'earth');
}

/** Calculate score based on aspects */
function calculateScore(
  aspect: number,
  influencingSign: ZodiacSign,
  targetSign: ZodiacSign,
  random: () => number
): number {
  const aspectScores: Record<number, number> = {
    0: 85, 1: 60, 2: 80, 3: 50, 4: 95, 5: 55, 6: 70,
  };

  let score = aspectScores[aspect] ?? 70;

  const targetElement = getElement(targetSign);
  const influenceElement = getElement(influencingSign);

  if (targetElement === influenceElement) {
    score += 10;
  } else if (areCompatibleElements(targetElement, influenceElement)) {
    score += 5;
  }

  // Add daily variation
  score += Math.floor(random() * 10) - 5;

  return Math.min(100, Math.max(40, score));
}

/** Generate lucky numbers */
function generateLuckyNumbers(random: () => number): number[] {
  const numbers = new Set<number>();
  while (numbers.size < 3) {
    numbers.add(Math.floor(random() * 49) + 1);
  }
  return Array.from(numbers).sort((a, b) => a - b);
}

/** Get lucky color */
function getLuckyColor(signIndex: number, weekday: number): string {
  const colors = [
    ['Kırmızı', 'Turuncu', 'Altın'],
    ['Yeşil', 'Pembe', 'Toprak Tonları'],
    ['Sarı', 'Açık Mavi', 'Gümüş'],
    ['Gümüş', 'Beyaz', 'Deniz Mavisi'],
    ['Altın', 'Turuncu', 'Mor'],
    ['Lacivert', 'Gri', 'Bej'],
    ['Pembe', 'Açık Mavi', 'Lavanta'],
    ['Bordo', 'Siyah', 'Koyu Kırmızı'],
    ['Mor', 'Mavi', 'Turkuaz'],
    ['Kahverengi', 'Siyah', 'Koyu Yeşil'],
    ['Elektrik Mavisi', 'Gümüş', 'Mor'],
    ['Deniz Yeşili', 'Lila', 'Aqua'],
  ];
  return colors[signIndex][weekday % 3];
}

/** Get planetary influence text */
function getPlanetaryInfluence(positions: ReturnType<typeof getCurrentPositions>, sign: ZodiacSign): string {
  const influences: string[] = [];

  if (positions.mercury.sign === sign) influences.push('Merkür');
  if (positions.venus.sign === sign) influences.push('Venüs');
  if (positions.mars.sign === sign) influences.push('Mars');
  if (positions.jupiter.sign === sign) influences.push('Jüpiter');
  if (positions.saturn.sign === sign) influences.push('Satürn');

  if (influences.length === 0) {
    return `Ay ${ZODIAC_TR[positions.moon.sign]} burcunda`;
  }
  return `${influences.join(', ')} etkisi altında`;
}

// ============ TEXT TEMPLATES ============

function getGeneralTemplates(moonAspect: number, sunAspect: number): string[] {
  if (moonAspect <= 2 && sunAspect <= 2) {
    return [
      'Bugün {sign} burçları için enerjik bir gün! Ay {moon_sign} burcunda ve size olumlu açılar yapıyor. {moon_phase} döneminde planlarınızı hayata geçirmek için ideal bir zaman.',
      '{sign} burcu, bugün kozmik enerjiler sizinle uyum içinde. {moon_sign} burcundaki Ay, sezgilerinizi güçlendiriyor. Kendinize güvenin!',
      'Gökyüzü bugün {sign} burçlarına gülümsüyor. {moon_phase} etkisiyle yaratıcılığınız dorukta olacak.',
      '{sign} için parlak bir gün! Ay\'ın {moon_sign} burcundaki konumu size şans getiriyor. Fırsatları değerlendirin.',
    ];
  } else if (moonAspect >= 4 || sunAspect >= 4) {
    return [
      '{sign} burcu, bugün biraz dikkatli olmanız gereken bir gün. Ay {moon_sign} burcunda zorlu açılar yapıyor. Sabırlı olun ve büyük kararları erteleyin.',
      'Bugün {sign} burçları için bazı engeller ortaya çıkabilir. {moon_phase} döneminde iç sesinizi dinleyin ve aceleden kaçının.',
      '{sign} burcu, kozmik enerjiler bugün sizi test edebilir. {moon_sign} Ay\'ı duygusal derinlik getiriyor.',
      'Zorluklarla karşılaşabilirsiniz {sign} burcu. Ama unutmayın, her zorluk bir öğrenme fırsatıdır.',
    ];
  } else {
    return [
      '{sign} burcu için dengeli bir gün. Ay {moon_sign} burcunda seyrederken, günlük rutinlerinize odaklanabilirsiniz.',
      'Bugün {sign} burçları için sakin ama verimli geçecek. {moon_sign} Ay\'ı pratik konulara dikkat çekiyor.',
      '{sign} burcu, bugün adım adım ilerleme günü. {moon_phase} döneminde küçük ama önemli detaylara dikkat edin.',
      'Ortalama tempoda bir gün {sign} burcu. Rutinlerinize sadık kalın ve enerjinizi koruyun.',
    ];
  }
}

function getLoveTemplates(score: number): string[] {
  if (score >= 75) {
    return [
      'Venüs {venus_sign} burcunda, aşk hayatınızı olumlu etkiliyor. İlişkinizde romantik anlar yaşayabilirsiniz.',
      'Bugün duygusal bağlarınız güçleniyor. {venus_sign} Venüs\'ü çekiciliğinizi artırıyor.',
      'Aşk kapınızı çalabilir! Venüs enerjisi sizinle ve yeni tanışmalar için açık olun.',
      'Romantizm havada! Partnerinizle özel bir akşam planlayabilirsiniz.',
    ];
  } else if (score >= 50) {
    return [
      'Aşk hayatında sakin bir gün. Venüs {venus_sign} burcunda, mevcut ilişkinize odaklanın.',
      'Duygusal konularda dengeli bir yaklaşım sergileyin. {venus_sign} Venüs\'ü sabır istiyor.',
      'İlişkilerde iletişim önemli. Partnerinizi dinlemeye zaman ayırın.',
      'Duygusal açıdan istikrarlı bir gün. Mevcut ilişkinizi besleyin.',
    ];
  } else {
    return [
      'Bugün duygusal konularda biraz mesafeli olabilirsiniz. Kendinize zaman tanıyın.',
      'Aşk hayatında beklenmedik gelişmeler olabilir. Sakin kalın ve tepkisel olmayın.',
      'Venüs {venus_sign} burcunda zorlayıcı açılar yapıyor. Sabırlı olun.',
      'İlişkilerde dikkatli olun. Yanlış anlaşılmalardan kaçının.',
    ];
  }
}

function getCareerTemplates(score: number): string[] {
  if (score >= 75) {
    return [
      'Mars {mars_sign} burcunda, kariyer hedefleriniz için harika bir gün! İnisiyatif alın.',
      'İş hayatında önemli fırsatlar kapınızı çalabilir. Enerjiniz yüksek, bunu değerlendirin.',
      'Profesyonel başarılar için ideal bir dönem. Projelerinizi ilerletin.',
      'Kariyer konusunda parlak fikirler üretebilirsiniz. Cesaretli adımlar atın.',
    ];
  } else if (score >= 50) {
    return [
      'Kariyer konusunda istikrarlı bir gün. {mars_sign} Mars\'ı düzenli çalışmayı destekliyor.',
      'İş yerinde rutin akışı koruyun. Büyük değişiklikler için henüz erken.',
      'Mesleki konularda sabırlı adımlar atın. Sonuçlar zamanla gelecek.',
      'İş hayatında sakin bir tempo. Detaylara dikkat edin.',
    ];
  } else {
    return [
      'İş hayatında bazı gecikmeler yaşanabilir. Planlarınızı esnek tutun.',
      'Kariyer hedeflerinizi gözden geçirmek için iyi bir gün. Aceleci olmayın.',
      'Mars {mars_sign} burcunda zorlu geçitler yapıyor. Çatışmalardan kaçının.',
      'Profesyonel konularda dikkatli olun. Önemli kararları erteleyin.',
    ];
  }
}

function getHealthTemplates(score: number): string[] {
  if (score >= 75) {
    return [
      'Bugün enerjiniz yüksek! Fiziksel aktiviteler için ideal bir gün.',
      'Sağlık durumunuz oldukça iyi. Yeni bir spor veya aktivite deneyebilirsiniz.',
      'Vücudunuz size olumlu sinyaller veriyor. Bu enerjiyi değerlendirin.',
      'Fiziksel ve mental olarak formdasınız. Aktif bir gün geçirin.',
    ];
  } else if (score >= 50) {
    return [
      'Sağlık açısından dengeli bir gün. Düzenli beslenmeye dikkat edin.',
      'Orta düzey aktiviteler bugün için ideal. Aşırıya kaçmayın.',
      'Kendinize bakım zamanı ayırın. Stres yönetimi önemli.',
      'Bedeninizi dinleyin ve ona saygı gösterin.',
    ];
  } else {
    return [
      'Bugün biraz yorgun hissedebilirsiniz. Dinlenmeye öncelik verin.',
      'Sağlık konusunda dikkatli olun. Bol su için ve erken yatın.',
      'Vücudunuzun sinyallerini dinleyin. Zorlayıcı aktivitelerden kaçının.',
      'Enerji seviyeniz düşük olabilir. Kendinize nazik davranın.',
    ];
  }
}

/** Generate daily horoscope for a sign */
export function generateDailyHoroscope(sign: ZodiacSign, date: Date = new Date()): DailyHoroscope {
  const signIndex = ZODIAC_SIGNS.indexOf(sign);
  const random = seededRandom(getDateSeed(date, signIndex));

  // Get current planetary positions
  const positions = getCurrentPositions('tr');

  // Calculate aspects
  const moonIndex = ZODIAC_SIGNS.indexOf(positions.moon.sign);
  const sunIndex = ZODIAC_SIGNS.indexOf(positions.sun.sign);
  const moonAspect = calculateAspect(signIndex, moonIndex);
  const sunAspect = calculateAspect(signIndex, sunIndex);

  // Calculate scores
  const loveScore = calculateScore(moonAspect, positions.venus.sign, sign, random);
  const careerScore = calculateScore(sunAspect, positions.mars.sign, sign, random);
  const healthScore = calculateScore(moonAspect, positions.saturn.sign, sign, random);
  const overallScore = Math.round((loveScore + careerScore + healthScore) / 3);

  // Generate texts
  const signTr = ZODIAC_TR[sign];
  const moonSignTr = ZODIAC_TR[positions.moon.sign];
  const venusSignTr = ZODIAC_TR[positions.venus.sign];
  const marsSignTr = ZODIAC_TR[positions.mars.sign];

  const generalTemplates = getGeneralTemplates(moonAspect, sunAspect);
  const loveTemplates = getLoveTemplates(loveScore);
  const careerTemplates = getCareerTemplates(careerScore);
  const healthTemplates = getHealthTemplates(healthScore);

  const general = generalTemplates[Math.floor(random() * generalTemplates.length)]
    .replace(/{sign}/g, signTr)
    .replace(/{moon_sign}/g, moonSignTr)
    .replace(/{moon_phase}/g, positions.moonPhase);

  const love = loveTemplates[Math.floor(random() * loveTemplates.length)]
    .replace(/{venus_sign}/g, venusSignTr);

  const career = careerTemplates[Math.floor(random() * careerTemplates.length)]
    .replace(/{mars_sign}/g, marsSignTr);

  const health = healthTemplates[Math.floor(random() * healthTemplates.length)];

  return {
    sign,
    signTr,
    date: date.toISOString().split('T')[0],
    general,
    love,
    career,
    health,
    scores: {
      overall: overallScore,
      love: loveScore,
      career: careerScore,
      health: healthScore,
    },
    luckyNumbers: generateLuckyNumbers(random),
    luckyColor: getLuckyColor(signIndex, date.getDay()),
    moonPhase: positions.moonPhase,
    planetaryInfluence: getPlanetaryInfluence(positions, sign),
  };
}

/** Generate horoscopes for all signs */
export function generateAllDailyHoroscopes(date: Date = new Date()): DailyHoroscope[] {
  return ZODIAC_SIGNS.map(sign => generateDailyHoroscope(sign, date));
}
