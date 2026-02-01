/**
 * Compatibility Report Edge Function (Optional)
 * Generates relationship compatibility analysis between two birth profiles
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { handleCors, jsonResponse, errorResponse } from '../_shared/cors.ts';
import { getLLMProviderFromEnv, LLMMessage } from '../_shared/llm_provider.ts';
import { checkRateLimit, incrementUsage, rateLimitError } from '../_shared/rate_limiter.ts';
import { validateOutput, logSecurityIssue } from '../_shared/sanitizer.ts';
import {
  parseCompatReportOutput,
  wrapPromptForJSON,
  COMPAT_REPORT_JSON_SCHEMA,
} from '../_shared/schema_validator.ts';

// Zodiac translations
const ZODIAC_TR: Record<string, string> = {
  aries: 'Koç', taurus: 'Boğa', gemini: 'İkizler', cancer: 'Yengeç',
  leo: 'Aslan', virgo: 'Başak', libra: 'Terazi', scorpio: 'Akrep',
  sagittarius: 'Yay', capricorn: 'Oğlak', aquarius: 'Kova', pisces: 'Balık',
};

const SYSTEM_PROMPT_TR = `Sen ilişki astrolojisi uzmanısın. İki kişinin doğum haritalarını karşılaştırarak uyum analizi yapıyorsun.

KURALLAR:
- Dengeli ve yapıcı bir yaklaşım kullan
- "Asla uyumlu olamazsınız" gibi kesin olumsuz ifadelerden kaçın
- Her ilişkinin güçlü ve geliştirilecek yanları olduğunu vurgula
- Pratik tavsiyeler sun
- Eğlence amaçlı olduğunu belirt

UYUM ANALİZİ İÇERİĞİ:
1. Genel uyum skoru (0-100)
2. Güçlü yönler (ilişkinin artıları)
3. Zorluklar (dikkat edilmesi gerekenler)
4. İlişki tavsiyeleri

Yanıtını JSON formatında ver.`;

const SYSTEM_PROMPT_EN = `You are a relationship astrology expert. You analyze compatibility by comparing two people's birth charts.

RULES:
- Use a balanced and constructive approach
- Avoid definitive negative statements like "you'll never be compatible"
- Emphasize that every relationship has strengths and areas for growth
- Offer practical advice
- Note that this is for entertainment

COMPATIBILITY ANALYSIS CONTENT:
1. Overall compatibility score (0-100)
2. Strengths (relationship positives)
3. Challenges (areas to watch)
4. Relationship advice

Respond in JSON format.`;

interface CompatReportRequest {
  partner_birth_date: string;
  partner_birth_city: string;
  partner_birth_country: string;
  partner_birth_time?: string;
  partner_name?: string;
  locale?: string;
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

    // Parse request
    const body: CompatReportRequest = await req.json();

    // Validate required fields
    if (!body.partner_birth_date) {
      return errorResponse('partner_birth_date is required', 400, 'validation_error');
    }
    if (!body.partner_birth_city) {
      return errorResponse('partner_birth_city is required', 400, 'validation_error');
    }
    if (!body.partner_birth_country) {
      return errorResponse('partner_birth_country is required', 400, 'validation_error');
    }

    // Validate date format
    const partnerDate = new Date(body.partner_birth_date);
    if (isNaN(partnerDate.getTime())) {
      return errorResponse('Invalid partner_birth_date format', 400, 'validation_error');
    }

    const locale = body.locale?.toLowerCase() === 'en' ? 'en' : 'tr';

    // Check rate limit (counts as astro_report)
    const rateLimit = await checkRateLimit(supabaseUrl, supabaseServiceKey, user.id, 'astro_report');
    if (!rateLimit.allowed) {
      return rateLimitError(rateLimit, 'compatibility report');
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

    // Get user's profile name
    const { data: userProfile } = await supabase
      .from('profiles')
      .select('name')
      .eq('id', user.id)
      .single();

    // Calculate zodiac signs
    const userBirthDate = new Date(birthProfile.birth_date);
    const userZodiac = getZodiacSign(userBirthDate);
    const partnerZodiac = getZodiacSign(partnerDate);

    const userZodiacLabel = locale === 'tr' ? ZODIAC_TR[userZodiac] : userZodiac;
    const partnerZodiacLabel = locale === 'tr' ? ZODIAC_TR[partnerZodiac] : partnerZodiac;

    const userName = userProfile?.name || (locale === 'tr' ? 'Kişi 1' : 'Person 1');
    const partnerName = body.partner_name || (locale === 'tr' ? 'Kişi 2' : 'Person 2');

    // Prepare prompt
    const userPrompt =
      locale === 'tr'
        ? `İki kişinin ilişki uyum analizi yap.

${userName}:
- Güneş burcu: ${userZodiacLabel}
- Doğum tarihi: ${birthProfile.birth_date}
- Doğum yeri: ${birthProfile.birth_city}, ${birthProfile.birth_country}
${birthProfile.birth_time ? `- Doğum saati: ${birthProfile.birth_time}` : ''}

${partnerName}:
- Güneş burcu: ${partnerZodiacLabel}
- Doğum tarihi: ${body.partner_birth_date}
- Doğum yeri: ${body.partner_birth_city}, ${body.partner_birth_country}
${body.partner_birth_time ? `- Doğum saati: ${body.partner_birth_time}` : ''}

Bu iki kişinin romantik ilişki uyumunu analiz et ve detaylı bir rapor hazırla.`
        : `Analyze the relationship compatibility of two people.

${userName}:
- Sun sign: ${userZodiacLabel}
- Birth date: ${birthProfile.birth_date}
- Birth place: ${birthProfile.birth_city}, ${birthProfile.birth_country}
${birthProfile.birth_time ? `- Birth time: ${birthProfile.birth_time}` : ''}

${partnerName}:
- Sun sign: ${partnerZodiacLabel}
- Birth date: ${body.partner_birth_date}
- Birth place: ${body.partner_birth_city}, ${body.partner_birth_country}
${body.partner_birth_time ? `- Birth time: ${body.partner_birth_time}` : ''}

Analyze the romantic relationship compatibility of these two people and prepare a detailed report.`;

    const systemPrompt = locale === 'tr' ? SYSTEM_PROMPT_TR : SYSTEM_PROMPT_EN;

    const messages: LLMMessage[] = [
      { role: 'system', content: wrapPromptForJSON(systemPrompt, COMPAT_REPORT_JSON_SCHEMA) },
      { role: 'user', content: userPrompt },
    ];

    // Call LLM
    const llmProvider = getLLMProviderFromEnv();
    const llmResponse = await llmProvider.generateCompletion(messages, {
      maxTokens: 2000,
      temperature: 0.7,
    });

    // Validate output
    const outputValidation = validateOutput(llmResponse.content);
    if (!outputValidation.valid) {
      logSecurityIssue(user.id, 'compat_report_output', outputValidation.issues, llmResponse.content);
    }

    // Parse output
    const parsedOutput = parseCompatReportOutput(llmResponse.content);
    if (!parsedOutput) {
      return errorResponse('Failed to generate compatibility report. Please try again.', 500, 'parse_error');
    }

    // Store as astro report with special type
    const serviceClient = createClient(supabaseUrl, supabaseServiceKey);

    const { data: report, error: insertError } = await serviceClient
      .from('astro_reports')
      .insert({
        user_id: user.id,
        report_type: 'love', // Stored as love report
        chart_json: {
          user: {
            name: userName,
            zodiac: userZodiac,
            birth_date: birthProfile.birth_date,
          },
          partner: {
            name: partnerName,
            zodiac: partnerZodiac,
            birth_date: body.partner_birth_date,
          },
          compatibility_score: parsedOutput.compatibility_score,
        },
        report_text: parsedOutput.summary,
        sections: {
          strengths: parsedOutput.strengths,
          challenges: parsedOutput.challenges,
          advice: parsedOutput.advice,
        },
        status: 'completed',
      })
      .select('id')
      .single();

    if (insertError) {
      console.error('Error storing compat report:', insertError);
    }

    // Increment usage
    await incrementUsage(supabaseUrl, supabaseServiceKey, user.id, 'astro_report');

    return jsonResponse({
      report_id: report?.id,
      user: {
        name: userName,
        zodiac_sign: userZodiac,
        zodiac_label: userZodiacLabel,
      },
      partner: {
        name: partnerName,
        zodiac_sign: partnerZodiac,
        zodiac_label: partnerZodiacLabel,
      },
      compatibility_score: parsedOutput.compatibility_score,
      summary: parsedOutput.summary,
      strengths: parsedOutput.strengths,
      challenges: parsedOutput.challenges,
      advice: parsedOutput.advice,
      remaining_today: rateLimit.remaining - 1,
      safety_note:
        locale === 'tr'
          ? 'Bu analiz eğlence amaçlıdır ve profesyonel ilişki tavsiyesi yerine geçmez.'
          : 'This analysis is for entertainment purposes and does not replace professional relationship advice.',
    });
  } catch (error) {
    console.error('Compat report error:', error);
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
