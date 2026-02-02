/**
 * STANDALONE - CRON Daily Generator Edge Function
 * Self-contained version for Supabase Dashboard deployment
 *
 * Generates daily affirmations for all 12 zodiac signs
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// ============================================================================
// INLINE: CORS UTILITIES
// ============================================================================
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
};

function handleCors(req: Request): Response | null {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }
  return null;
}

function jsonResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

function errorResponse(message: string, status = 400, code?: string): Response {
  return jsonResponse({ error: code || 'error', message }, status);
}

// ============================================================================
// INLINE: LLM PROVIDER (OpenAI)
// ============================================================================
interface LLMMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

interface LLMResponse {
  content: string;
  model: string;
}

async function generateCompletion(
  messages: LLMMessage[],
  options: { maxTokens?: number; temperature?: number } = {}
): Promise<LLMResponse> {
  const apiKey = Deno.env.get('OPENAI_API_KEY');
  if (!apiKey) {
    throw new Error('OPENAI_API_KEY not configured');
  }

  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model: Deno.env.get('LLM_MODEL') || 'gpt-4o-mini',
      messages: messages.map((m) => ({ role: m.role, content: m.content })),
      max_tokens: options.maxTokens || 4000,
      temperature: options.temperature || 0.8,
    }),
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`OpenAI API error: ${response.status} - ${error}`);
  }

  const data = await response.json();
  return {
    content: data.choices[0].message.content,
    model: data.model,
  };
}

// ============================================================================
// CONSTANTS
// ============================================================================
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

const THEMES = ['love', 'career', 'health', 'spiritual', 'general', 'creativity', 'relationships'];
const LUCKY_COLORS = [
  'kırmızı', 'mavi', 'yeşil', 'sarı', 'mor', 'turuncu', 'pembe',
  'beyaz', 'siyah', 'gri', 'turkuaz', 'lacivert', 'bordo', 'altın'
];
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

// ============================================================================
// MAIN HANDLER
// ============================================================================
serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    // Verify service role key (this should only be called by CRON)
    const authHeader = req.headers.get('Authorization');
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

    if (!authHeader || !authHeader.includes(supabaseServiceKey)) {
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
      console.log(`Affirmations for ${targetDateStr} already exist`);
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

    const llmResponse = await generateCompletion(messages, {
      maxTokens: 4000,
      temperature: 0.8,
    });

    // Parse response
    let result: GenerationResult;
    try {
      const jsonMatch = llmResponse.content.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        throw new Error('No JSON found in response');
      }
      result = JSON.parse(jsonMatch[0]);
    } catch (parseError) {
      console.error('Failed to parse LLM response:', parseError);
      return errorResponse('Failed to parse AI response', 500, 'parse_error');
    }

    // Validate we have 12 signs, fill missing with fallback
    if (!result.affirmations || result.affirmations.length < 12) {
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
    content_text: `Bugün ${signLabel} burcu için evrenin enerjisi sizinle. İçsel gücünüze güvenin ve yolunuza ışık tutmasına izin verin.`,
    theme: randomTheme,
    mood_keywords: ['pozitif', 'enerjik', 'umutlu'],
    lucky_number: Math.floor(Math.random() * 99) + 1,
    lucky_color: randomColor,
    power_crystal: randomCrystal,
  };
}
