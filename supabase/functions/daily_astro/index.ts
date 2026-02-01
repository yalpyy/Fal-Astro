/**
 * Daily Astro Edge Function
 * Generates personalized daily horoscope based on user's birth profile
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { handleCors, jsonResponse, errorResponse } from '../_shared/cors.ts';
import { getLLMProviderFromEnv, LLMMessage } from '../_shared/llm_provider.ts';
import { checkRateLimit, incrementUsage, rateLimitError } from '../_shared/rate_limiter.ts';
import { validateOutput, logSecurityIssue } from '../_shared/sanitizer.ts';
import {
  parseDailyAstroOutput,
  wrapPromptForJSON,
  DAILY_ASTRO_JSON_SCHEMA,
} from '../_shared/schema_validator.ts';

// Zodiac sign translations
const ZODIAC_TR: Record<string, string> = {
  aries: 'Koç',
  taurus: 'Boğa',
  gemini: 'İkizler',
  cancer: 'Yengeç',
  leo: 'Aslan',
  virgo: 'Başak',
  libra: 'Terazi',
  scorpio: 'Akrep',
  sagittarius: 'Yay',
  capricorn: 'Oğlak',
  aquarius: 'Kova',
  pisces: 'Balık',
};

const DAILY_SYSTEM_PROMPT_TR = `Sen deneyimli bir astrologsun. Kişinin doğum haritasına göre günlük kişisel yorum yapıyorsun.

KURALLAR:
- Pozitif ve motive edici bir ton kullan
- Kesin tahminlerden kaçın
- Sağlık ve finans konularında tavsiye verme
- Günün enerjisine ve potansiyel fırsatlara odaklan
- Kısa ve öz tut (2-3 paragraf)

YORUM İÇERİĞİ:
1. Günün genel enerjisi
2. Dikkat edilmesi gereken alanlar
3. Şans faktörleri
4. Kısa tavsiye

Yanıtını JSON formatında ver.`;

const DAILY_SYSTEM_PROMPT_EN = `You are an experienced astrologer. You provide personalized daily horoscopes based on the person's birth chart.

RULES:
- Use a positive and motivating tone
- Avoid definitive predictions
- Don't give health or financial advice
- Focus on the day's energy and potential opportunities
- Keep it brief (2-3 paragraphs)

CONTENT:
1. General energy of the day
2. Areas to pay attention to
3. Luck factors
4. Brief advice

Respond in JSON format.`;

interface DailyAstroRequest {
  locale?: string;
  force_refresh?: boolean;
}

serve(async (req: Request) => {
  // Handle CORS
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    // Verify authorization
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return errorResponse('Missing authorization header', 401, 'unauthorized');
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: {
        headers: { Authorization: authHeader },
      },
    });

    // Get user from JWT
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser();

    if (authError || !user) {
      return errorResponse('Invalid or expired token', 401, 'unauthorized');
    }

    // Parse request body
    let body: DailyAstroRequest = {};
    try {
      body = await req.json();
    } catch {
      // Body is optional
    }

    const locale = body.locale?.toLowerCase() === 'en' ? 'en' : 'tr';
    const today = new Date().toISOString().split('T')[0];

    // Service client for privileged operations
    const serviceClient = createClient(supabaseUrl, supabaseServiceKey);

    // Check cache first (unless force refresh)
    if (!body.force_refresh) {
      const { data: cached } = await supabase
        .from('daily_astro_cache')
        .select('*')
        .eq('user_id', user.id)
        .eq('date', today)
        .single();

      if (cached) {
        return jsonResponse({
          content: cached.content,
          mood_score: cached.mood_score,
          lucky_numbers: cached.lucky_numbers,
          lucky_color: cached.lucky_color,
          zodiac_sign: cached.zodiac_sign,
          date: cached.date,
          cached: true,
        });
      }
    }

    // Check rate limit
    const rateLimit = await checkRateLimit(supabaseUrl, supabaseServiceKey, user.id, 'daily_astro');
    if (!rateLimit.allowed) {
      return rateLimitError(rateLimit, 'daily astro');
    }

    // Get user's birth profile
    const { data: birthProfile, error: profileError } = await supabase
      .from('birth_profiles')
      .select('*')
      .eq('user_id', user.id)
      .single();

    if (profileError || !birthProfile) {
      return errorResponse('Birth profile not found. Please complete your profile first.', 404, 'profile_not_found');
    }

    // Calculate zodiac sign
    const birthDate = new Date(birthProfile.birth_date);
    const zodiacSign = getZodiacSign(birthDate);
    const zodiacLabel = locale === 'tr' ? ZODIAC_TR[zodiacSign] : zodiacSign;

    // Prepare prompt
    const userPrompt =
      locale === 'tr'
        ? `Bugün ${new Date().toLocaleDateString('tr-TR', { weekday: 'long', day: 'numeric', month: 'long' })} için ${zodiacLabel} burcu günlük yorum.

Kişi bilgileri:
- Doğum tarihi: ${birthProfile.birth_date}
- Doğum yeri: ${birthProfile.birth_city}, ${birthProfile.birth_country}
${birthProfile.birth_time ? `- Doğum saati: ${birthProfile.birth_time}` : ''}

Kişiye özel, sıcak ve samimi bir günlük yorum yap.`
        : `Daily horoscope for ${zodiacLabel} on ${new Date().toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })}.

Person's info:
- Birth date: ${birthProfile.birth_date}
- Birth place: ${birthProfile.birth_city}, ${birthProfile.birth_country}
${birthProfile.birth_time ? `- Birth time: ${birthProfile.birth_time}` : ''}

Provide a personalized, warm, and friendly daily reading.`;

    const systemPrompt = locale === 'tr' ? DAILY_SYSTEM_PROMPT_TR : DAILY_SYSTEM_PROMPT_EN;

    const messages: LLMMessage[] = [
      { role: 'system', content: wrapPromptForJSON(systemPrompt, DAILY_ASTRO_JSON_SCHEMA) },
      { role: 'user', content: userPrompt },
    ];

    // Call LLM
    const llmProvider = getLLMProviderFromEnv();
    const llmResponse = await llmProvider.generateCompletion(messages, {
      maxTokens: 1024,
      temperature: 0.7,
    });

    // Validate output
    const outputValidation = validateOutput(llmResponse.content);
    if (!outputValidation.valid) {
      logSecurityIssue(user.id, 'daily_astro_output', outputValidation.issues, llmResponse.content);
    }

    // Parse output
    const parsedOutput = parseDailyAstroOutput(llmResponse.content);
    if (!parsedOutput) {
      return errorResponse('Failed to generate daily reading. Please try again.', 500, 'parse_error');
    }

    // Cache the result
    const { error: cacheError } = await serviceClient.from('daily_astro_cache').upsert({
      user_id: user.id,
      date: today,
      zodiac_sign: zodiacSign,
      content: parsedOutput.content,
      mood_score: parsedOutput.mood_score,
      lucky_numbers: parsedOutput.lucky_numbers,
      lucky_color: parsedOutput.lucky_color,
    });

    if (cacheError) {
      console.error('Error caching daily astro:', cacheError);
    }

    // Increment usage
    await incrementUsage(supabaseUrl, supabaseServiceKey, user.id, 'daily_astro');

    return jsonResponse({
      ...parsedOutput,
      zodiac_sign: zodiacSign,
      zodiac_label: zodiacLabel,
      date: today,
      cached: false,
      remaining_today: rateLimit.remaining - 1,
    });
  } catch (error) {
    console.error('Daily astro error:', error);
    return errorResponse(
      error instanceof Error ? error.message : 'Internal server error',
      500,
      'server_error'
    );
  }
});

// Helper to calculate zodiac sign
function getZodiacSign(date: Date): string {
  const month = date.getMonth() + 1;
  const day = date.getDate();

  if ((month === 3 && day >= 21) || (month === 4 && day <= 19)) return 'aries';
  if ((month === 4 && day >= 20) || (month === 5 && day <= 20)) return 'taurus';
  if ((month === 5 && day >= 21) || (month === 6 && day <= 20)) return 'gemini';
  if ((month === 6 && day >= 21) || (month === 7 && day <= 22)) return 'cancer';
  if ((month === 7 && day >= 23) || (month === 8 && day <= 22)) return 'leo';
  if ((month === 8 && day >= 23) || (month === 9 && day <= 22)) return 'virgo';
  if ((month === 9 && day >= 23) || (month === 10 && day <= 22)) return 'libra';
  if ((month === 10 && day >= 23) || (month === 11 && day <= 21)) return 'scorpio';
  if ((month === 11 && day >= 22) || (month === 12 && day <= 21)) return 'sagittarius';
  if ((month === 12 && day >= 22) || (month === 1 && day <= 19)) return 'capricorn';
  if ((month === 1 && day >= 20) || (month === 2 && day <= 18)) return 'aquarius';
  return 'pisces';
}
