/**
 * CRON Daily Generator Edge Function
 * Automatically generates daily affirmations for all 12 zodiac signs
 * Triggered by Supabase CRON job (recommended: 03:00 AM daily)
 *
 * Setup:
 * 1. Deploy this function: supabase functions deploy cron-daily-generator
 * 2. Create CRON job in Supabase Dashboard -> Database -> Extensions -> pg_cron
 *    SELECT cron.schedule(
 *      'daily-affirmation-generator',
 *      '0 3 * * *',
 *      $$SELECT net.http_post(
 *        url := 'https://YOUR_PROJECT.supabase.co/functions/v1/cron-daily-generator',
 *        headers := '{"Authorization": "Bearer YOUR_SERVICE_ROLE_KEY", "Content-Type": "application/json"}'::jsonb,
 *        body := '{"generate_for": "tomorrow"}'::jsonb
 *      )$$
 *    );
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { handleCors, jsonResponse, errorResponse } from '../_shared/cors.ts';
import { getLLMProviderFromEnv, LLMMessage } from '../_shared/llm_provider.ts';

// Zodiac signs
const ZODIAC_SIGNS = [
  'aries', 'taurus', 'gemini', 'cancer',
  'leo', 'virgo', 'libra', 'scorpio',
  'sagittarius', 'capricorn', 'aquarius', 'pisces'
];

const ZODIAC_TR: Record<string, string> = {
  aries: 'Koç', taurus: 'Boğa', gemini: 'İkizler', cancer: 'Yengeç',
  leo: 'Aslan', virgo: 'Başak', libra: 'Terazi', scorpio: 'Akrep',
  sagittarius: 'Yay', capricorn: 'Oğlak', aquarius: 'Kova', pisces: 'Balık',
};

// Themes for variety
const THEMES = ['love', 'career', 'health', 'spiritual', 'general', 'creativity', 'relationships'];

// Lucky colors pool
const LUCKY_COLORS = [
  'kırmızı', 'mavi', 'yeşil', 'sarı', 'mor', 'turuncu', 'pembe',
  'beyaz', 'siyah', 'gri', 'turkuaz', 'lacivert', 'bordo', 'altın'
];

// Power crystals
const POWER_CRYSTALS = [
  'Ametist', 'Kuvars', 'Akik', 'Turkuaz', 'Yeşim', 'Kehribar',
  'Obsidyen', 'Lapis Lazuli', 'Ay Taşı', 'Sitrin', 'Rodonit', 'Hematit'
];

const SYSTEM_PROMPT = `Sen mistik ve ilham verici bir astrologsun. Her burç için günlük olumlamalar (affirmations) yazıyorsun.

KURALLAR:
- Her mesaj pozitif, güçlendirici ve ilham verici olmalı
- Korkutucu veya negatif içerik YASAK
- Her burç için benzersiz ve o burcun özelliklerine uygun yaz
- Türkçe yaz
- Mesajlar 2-3 cümle olsun, çok uzun olmasın
- Mistik ve şiirsel bir dil kullan

JSON formatında yanıt ver.`;

const generatePrompt = (targetDate: string) => `
${targetDate} tarihi için 12 burç için günlük olumlamalar oluştur.

Her burç için şunları ver:
- content_text: Günlük olumlama mesajı (2-3 cümle, pozitif, ilham verici)
- theme: Tema (love/career/health/spiritual/general/creativity/relationships)
- mood_keywords: 3 ruh hali kelimesi (array)
- lucky_number: Şanslı sayı (1-99)
- lucky_color: Şanslı renk (Türkçe)
- power_crystal: Güç kristali

Yanıtı şu JSON formatında ver:
{
  "affirmations": [
    {
      "zodiac_sign": "aries",
      "content_text": "...",
      "theme": "...",
      "mood_keywords": ["...", "...", "..."],
      "lucky_number": 7,
      "lucky_color": "kırmızı",
      "power_crystal": "Ametist"
    },
    ... (12 burç için)
  ]
}`;

interface AffirmationData {
  zodiac_sign: string;
  content_text: string;
  theme: string;
  mood_keywords: string[];
  lucky_number: number;
  lucky_color: string;
  power_crystal: string;
}

interface GenerationResult {
  affirmations: AffirmationData[];
}

serve(async (req: Request) => {
  // Handle CORS
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    // Verify service role key (this should only be called by CRON)
    const authHeader = req.headers.get('Authorization');
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

    if (!authHeader || !authHeader.includes(supabaseServiceKey)) {
      // Allow with service key in header
      const expectedAuth = `Bearer ${supabaseServiceKey}`;
      if (authHeader !== expectedAuth) {
        console.log('Unauthorized access attempt to cron-daily-generator');
        return errorResponse('Unauthorized - Service role key required', 401, 'unauthorized');
      }
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Parse request
    const body = await req.json().catch(() => ({}));
    const generateFor = body.generate_for || 'tomorrow';
    const locale = body.locale || 'tr';

    // Calculate target date
    const today = new Date();
    let targetDate: Date;

    if (generateFor === 'tomorrow') {
      targetDate = new Date(today);
      targetDate.setDate(today.getDate() + 1);
    } else if (generateFor === 'today') {
      targetDate = today;
    } else {
      // Assume it's a date string
      targetDate = new Date(generateFor);
    }

    const targetDateStr = targetDate.toISOString().split('T')[0];

    console.log(`Generating daily affirmations for ${targetDateStr}`);

    // Check if already generated
    const { data: existing } = await supabase
      .from('daily_affirmations')
      .select('zodiac_sign')
      .eq('date', targetDateStr)
      .eq('locale', locale);

    if (existing && existing.length >= 12) {
      console.log(`Affirmations for ${targetDateStr} already exist (${existing.length} signs)`);
      return jsonResponse({
        success: true,
        message: 'Affirmations already generated',
        date: targetDateStr,
        count: existing.length,
        skipped: true,
      });
    }

    // Generate with LLM
    const messages: LLMMessage[] = [
      { role: 'system', content: SYSTEM_PROMPT },
      { role: 'user', content: generatePrompt(targetDateStr) },
    ];

    const llmProvider = getLLMProviderFromEnv();
    const llmResponse = await llmProvider.generateCompletion(messages, {
      maxTokens: 4000,
      temperature: 0.8, // Higher for creativity
    });

    // Parse response
    let result: GenerationResult;
    try {
      // Extract JSON from response
      const jsonMatch = llmResponse.content.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        throw new Error('No JSON found in response');
      }
      result = JSON.parse(jsonMatch[0]);
    } catch (parseError) {
      console.error('Failed to parse LLM response:', parseError);
      console.error('Raw response:', llmResponse.content);
      return errorResponse('Failed to parse AI response', 500, 'parse_error');
    }

    // Validate we have 12 signs
    if (!result.affirmations || result.affirmations.length < 12) {
      console.error('Incomplete response - got', result.affirmations?.length || 0, 'signs');

      // Fill missing signs with fallback
      const existingSigns = new Set(result.affirmations?.map(a => a.zodiac_sign) || []);
      const missingSigns = ZODIAC_SIGNS.filter(s => !existingSigns.has(s));

      for (const sign of missingSigns) {
        result.affirmations = result.affirmations || [];
        result.affirmations.push(generateFallbackAffirmation(sign));
      }
    }

    // Prepare data for insert
    const insertData = result.affirmations.map(aff => ({
      date: targetDateStr,
      zodiac_sign: aff.zodiac_sign.toLowerCase(),
      content_text: aff.content_text,
      theme: aff.theme,
      mood_keywords: aff.mood_keywords,
      lucky_number: aff.lucky_number,
      lucky_color: aff.lucky_color,
      power_crystal: aff.power_crystal,
      locale: locale,
      is_manually_edited: false,
      generated_at: new Date().toISOString(),
    }));

    // Upsert to handle partial existing data
    const { data: inserted, error: insertError } = await supabase
      .from('daily_affirmations')
      .upsert(insertData, {
        onConflict: 'date,zodiac_sign,locale',
        ignoreDuplicates: false,
      })
      .select();

    if (insertError) {
      console.error('Database insert error:', insertError);
      return errorResponse(`Database error: ${insertError.message}`, 500, 'db_error');
    }

    console.log(`Successfully generated ${inserted?.length || 0} affirmations for ${targetDateStr}`);

    // Also generate daily tarot (optional)
    await generateDailyTarot(supabase, targetDateStr, locale).catch(err => {
      console.error('Tarot generation failed (non-fatal):', err);
    });

    return jsonResponse({
      success: true,
      message: 'Daily content generated successfully',
      date: targetDateStr,
      affirmations_count: inserted?.length || 0,
      locale: locale,
    });

  } catch (error) {
    console.error('CRON daily generator error:', error);
    return errorResponse(
      error instanceof Error ? error.message : 'Internal server error',
      500,
      'server_error'
    );
  }
});

// Fallback affirmation for missing signs
function generateFallbackAffirmation(sign: string): AffirmationData {
  const signLabel = ZODIAC_TR[sign] || sign;
  const randomTheme = THEMES[Math.floor(Math.random() * THEMES.length)];
  const randomColor = LUCKY_COLORS[Math.floor(Math.random() * LUCKY_COLORS.length)];
  const randomCrystal = POWER_CRYSTALS[Math.floor(Math.random() * POWER_CRYSTALS.length)];

  return {
    zodiac_sign: sign,
    content_text: `Bugün ${signLabel} burcu için evrenin enerjisi sizinle. İçsel gücünüze güvenin ve yolunuza ışık tutmasına izin verin. ✨`,
    theme: randomTheme,
    mood_keywords: ['pozitif', 'enerjik', 'umutlu'],
    lucky_number: Math.floor(Math.random() * 99) + 1,
    lucky_color: randomColor,
    power_crystal: randomCrystal,
  };
}

// Generate daily tarot cards
async function generateDailyTarot(supabase: any, date: string, locale: string) {
  // Simple tarot card pool (Major Arcana)
  const TAROT_CARDS = [
    { name: 'The Fool', name_tr: 'Deli', meaning: 'Yeni başlangıçlar, masumiyet, spontanlık' },
    { name: 'The Magician', name_tr: 'Büyücü', meaning: 'İrade gücü, yaratıcılık, beceri' },
    { name: 'The High Priestess', name_tr: 'Başrahibe', meaning: 'Sezgi, bilinçaltı, gizem' },
    { name: 'The Empress', name_tr: 'İmparatoriçe', meaning: 'Bereket, doğa, bolluk' },
    { name: 'The Emperor', name_tr: 'İmparator', meaning: 'Otorite, yapı, kontrol' },
    { name: 'The Hierophant', name_tr: 'Aziz', meaning: 'Gelenek, uyum, manevi rehberlik' },
    { name: 'The Lovers', name_tr: 'Aşıklar', meaning: 'Aşk, uyum, ilişkiler' },
    { name: 'The Chariot', name_tr: 'Savaş Arabası', meaning: 'İrade, zafer, kararlılık' },
    { name: 'Strength', name_tr: 'Güç', meaning: 'Cesaret, sabır, iç güç' },
    { name: 'The Hermit', name_tr: 'Ermiş', meaning: 'İçe bakış, arayış, rehberlik' },
    { name: 'Wheel of Fortune', name_tr: 'Kader Çarkı', meaning: 'Değişim, döngüler, şans' },
    { name: 'Justice', name_tr: 'Adalet', meaning: 'Denge, dürüstlük, hukuk' },
    { name: 'The Hanged Man', name_tr: 'Asılan Adam', meaning: 'Fedakarlık, yeni bakış açısı' },
    { name: 'Death', name_tr: 'Ölüm', meaning: 'Dönüşüm, son, yeni başlangıç' },
    { name: 'Temperance', name_tr: 'İtidal', meaning: 'Denge, sabır, orta yol' },
    { name: 'The Devil', name_tr: 'Şeytan', meaning: 'Bağımlılık, maddecilik, gölge' },
    { name: 'The Tower', name_tr: 'Kule', meaning: 'Ani değişim, kaos, aydınlanma' },
    { name: 'The Star', name_tr: 'Yıldız', meaning: 'Umut, ilham, huzur' },
    { name: 'The Moon', name_tr: 'Ay', meaning: 'İllüzyon, korku, bilinçaltı' },
    { name: 'The Sun', name_tr: 'Güneş', meaning: 'Başarı, mutluluk, canlılık' },
    { name: 'Judgement', name_tr: 'Mahkeme', meaning: 'Yargı, yenilenme, çağrı' },
    { name: 'The World', name_tr: 'Dünya', meaning: 'Tamamlanma, başarı, bütünlük' },
  ];

  const tarotData = ZODIAC_SIGNS.map(sign => {
    const card = TAROT_CARDS[Math.floor(Math.random() * TAROT_CARDS.length)];
    const isReversed = Math.random() > 0.7; // 30% chance of reversed

    return {
      date: date,
      zodiac_sign: sign,
      card_name: locale === 'tr' ? card.name_tr : card.name,
      card_meaning_tr: card.meaning,
      is_reversed: isReversed,
      locale: locale,
    };
  });

  await supabase
    .from('daily_tarot')
    .upsert(tarotData, { onConflict: 'date,zodiac_sign,locale' });
}
