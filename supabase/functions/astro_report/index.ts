/**
 * Astro Report Edge Function
 * Generates natal, weekly, monthly, yearly, love, and career reports
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { handleCors, jsonResponse, errorResponse } from '../_shared/cors.ts';
import { getLLMProviderFromEnv, LLMMessage } from '../_shared/llm_provider.ts';
import { checkRateLimit, incrementUsage, rateLimitError } from '../_shared/rate_limiter.ts';
import { validateOutput, validateReportType, logSecurityIssue } from '../_shared/sanitizer.ts';
import {
  parseAstroReportOutput,
  wrapPromptForJSON,
  ASTRO_REPORT_JSON_SCHEMA,
} from '../_shared/schema_validator.ts';
import {
  calculateNatalChart,
  getSunSign,
  ZODIAC_TR,
  ZodiacSign,
} from '../_shared/astrology_calculator.ts';

// Report type prompts
const REPORT_PROMPTS: Record<string, { tr: string; en: string }> = {
  natal: {
    tr: `Doğum haritası analizi yap. Kişilik özellikleri, güçlü yanlar, gelişim alanları, yaşam amacı ve genel potansiyel hakkında detaylı bir natal rapor hazırla.`,
    en: `Create a birth chart analysis. Prepare a detailed natal report about personality traits, strengths, growth areas, life purpose, and general potential.`,
  },
  weekly: {
    tr: `Bu hafta için detaylı bir astroloji yorumu hazırla. Haftanın enerjisi, önemli günler, dikkat edilmesi gereken konular ve fırsatlar hakkında bilgi ver.`,
    en: `Prepare a detailed astrology reading for this week. Provide information about the week's energy, important days, areas to watch, and opportunities.`,
  },
  monthly: {
    tr: `Bu ay için kapsamlı bir astroloji yorumu hazırla. Ayın genel enerjisi, kariyer, aşk, sağlık ve finans alanlarında beklentiler hakkında bilgi ver.`,
    en: `Prepare a comprehensive astrology reading for this month. Provide expectations about the month's general energy, career, love, health, and finance.`,
  },
  yearly: {
    tr: `Bu yıl için kapsamlı bir astroloji yorumu hazırla. Yılın ana temaları, önemli dönemler, fırsatlar ve zorluklar hakkında detaylı bilgi ver.`,
    en: `Prepare a comprehensive astrology reading for this year. Provide detailed information about main themes, important periods, opportunities, and challenges.`,
  },
  love: {
    tr: `Aşk ve ilişkiler konusunda detaylı bir astroloji yorumu hazırla. İlişki dinamikleri, uyum özellikleri, beklentiler ve tavsiyeler ver.`,
    en: `Prepare a detailed astrology reading about love and relationships. Provide relationship dynamics, compatibility traits, expectations, and advice.`,
  },
  career: {
    tr: `Kariyer ve iş hayatı konusunda detaylı bir astroloji yorumu hazırla. Kariyer potansiyeli, uygun alanlar, fırsatlar ve tavsiyeler ver.`,
    en: `Prepare a detailed astrology reading about career and work life. Provide career potential, suitable fields, opportunities, and advice.`,
  },
};

const SYSTEM_PROMPT_TR = `Sen profesyonel bir astrologsun. Doğum haritalarını analiz ederek detaylı ve içgörülü raporlar hazırlıyorsun.

KURALLAR:
- Bilgilendirici ve pozitif bir ton kullan
- Kesin tahminlerden kaçın, olasılıklar ve eğilimlerden bahset
- Tıbbi, hukuki veya finansal tavsiye verme
- Korkutucu veya endişe verici ifadelerden kaçın
- Kişinin potansiyelini ve fırsatlarını vurgula
- Bu bilgilerin eğlence amaçlı olduğunu belirt

Yanıtını JSON formatında ver.`;

const SYSTEM_PROMPT_EN = `You are a professional astrologer. You analyze birth charts to prepare detailed and insightful reports.

RULES:
- Use an informative and positive tone
- Avoid definitive predictions, speak of possibilities and tendencies
- Don't give medical, legal, or financial advice
- Avoid scary or worrying statements
- Highlight the person's potential and opportunities
- Note that this is for entertainment purposes

Respond in JSON format.`;

interface AstroReportRequest {
  report_type: string;
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
    const body: AstroReportRequest = await req.json();

    if (!body.report_type || !validateReportType(body.report_type)) {
      return errorResponse(
        'Valid report_type required (natal, weekly, monthly, yearly, love, career)',
        400,
        'validation_error'
      );
    }

    const locale = body.locale?.toLowerCase() === 'en' ? 'en' : 'tr';
    const reportType = body.report_type.toLowerCase();

    // Check rate limit
    const rateLimit = await checkRateLimit(supabaseUrl, supabaseServiceKey, user.id, 'astro_report');
    if (!rateLimit.allowed) {
      return rateLimitError(rateLimit, 'astro report');
    }

    // Check for recent report of same type (to avoid duplicates)
    const serviceClient = createClient(supabaseUrl, supabaseServiceKey);

    // For periodic reports, check validity
    if (['weekly', 'monthly', 'yearly'].includes(reportType)) {
      const { data: existingReport } = await supabase
        .from('astro_reports')
        .select('*')
        .eq('user_id', user.id)
        .eq('report_type', reportType)
        .eq('status', 'completed')
        .gte('valid_until', new Date().toISOString().split('T')[0])
        .order('created_at', { ascending: false })
        .limit(1)
        .single();

      if (existingReport) {
        return jsonResponse({
          ...existingReport,
          cached: true,
        });
      }
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

    // Calculate zodiac sign and natal chart using astronomical algorithms
    const birthDate = new Date(birthProfile.birth_date);

    // Parse birth time if available
    let birthDateTime = birthDate;
    if (birthProfile.birth_time) {
      const [hours, minutes] = birthProfile.birth_time.split(':').map(Number);
      birthDateTime = new Date(birthDate);
      birthDateTime.setHours(hours || 0, minutes || 0, 0, 0);
    }

    // Get coordinates from birth location (using approximate coordinates)
    const latitude = birthProfile.birth_latitude ?? 41.0082; // Default: Istanbul
    const longitude = birthProfile.birth_longitude ?? 28.9784;

    // Calculate full natal chart using offline astronomical algorithms
    const natalChart = calculateNatalChart(
      birthDateTime,
      birthProfile.birth_time ? latitude : undefined,
      birthProfile.birth_time ? longitude : undefined,
      locale === 'tr' ? 'tr' : 'en'
    );

    const zodiacSign = natalChart.sun.sign;
    const zodiacLabel = locale === 'tr' ? ZODIAC_TR[zodiacSign] : zodiacSign;

    // Build chart JSON with real calculated values
    const chartJson = {
      sun: { sign: natalChart.sun.sign, degree: Math.round(natalChart.sun.degree * 10) / 10 },
      moon: { sign: natalChart.moon.sign, degree: Math.round(natalChart.moon.degree * 10) / 10 },
      ascendant: natalChart.rising
        ? { sign: natalChart.rising.sign, degree: Math.round(natalChart.rising.degree * 10) / 10 }
        : 'unknown',
      mercury: { sign: natalChart.mercury.sign, degree: Math.round(natalChart.mercury.degree * 10) / 10 },
      venus: { sign: natalChart.venus.sign, degree: Math.round(natalChart.venus.degree * 10) / 10 },
      mars: { sign: natalChart.mars.sign, degree: Math.round(natalChart.mars.degree * 10) / 10 },
      jupiter: { sign: natalChart.jupiter.sign, degree: Math.round(natalChart.jupiter.degree * 10) / 10 },
      saturn: { sign: natalChart.saturn.sign, degree: Math.round(natalChart.saturn.degree * 10) / 10 },
      moonPhase: natalChart.moonPhase,
    };

    // Prepare prompt
    const reportPrompt = REPORT_PROMPTS[reportType];
    const specificPrompt = locale === 'tr' ? reportPrompt.tr : reportPrompt.en;

    // Build chart description for prompt
    const moonLabel = locale === 'tr' ? ZODIAC_TR[natalChart.moon.sign] : natalChart.moon.sign;
    const mercuryLabel = locale === 'tr' ? ZODIAC_TR[natalChart.mercury.sign] : natalChart.mercury.sign;
    const venusLabel = locale === 'tr' ? ZODIAC_TR[natalChart.venus.sign] : natalChart.venus.sign;
    const marsLabel = locale === 'tr' ? ZODIAC_TR[natalChart.mars.sign] : natalChart.mars.sign;
    const risingLabel = natalChart.rising
      ? (locale === 'tr' ? ZODIAC_TR[natalChart.rising.sign] : natalChart.rising.sign)
      : null;

    const userPrompt =
      locale === 'tr'
        ? `${specificPrompt}

Kişi bilgileri:
- Güneş burcu: ${zodiacLabel} (${Math.round(natalChart.sun.degree)}°)
- Ay burcu: ${moonLabel} (${Math.round(natalChart.moon.degree)}°)
${risingLabel ? `- Yükselen burç: ${risingLabel} (${Math.round(natalChart.rising!.degree)}°)` : '- Yükselen burç: Doğum saati bilinmediği için hesaplanamadı'}
- Merkür: ${mercuryLabel}
- Venüs: ${venusLabel}
- Mars: ${marsLabel}
- Ay fazı: ${natalChart.moonPhase}
- Doğum tarihi: ${birthProfile.birth_date}
- Doğum yeri: ${birthProfile.birth_city}, ${birthProfile.birth_country}
${birthProfile.birth_time ? `- Doğum saati: ${birthProfile.birth_time}` : ''}

Bu natal harita verilerine dayanarak detaylı ve kişiye özel bir rapor hazırla.`
        : `${specificPrompt}

Person's chart data:
- Sun sign: ${zodiacLabel} (${Math.round(natalChart.sun.degree)}°)
- Moon sign: ${moonLabel} (${Math.round(natalChart.moon.degree)}°)
${risingLabel ? `- Rising sign: ${risingLabel} (${Math.round(natalChart.rising!.degree)}°)` : '- Rising sign: Cannot be calculated without birth time'}
- Mercury: ${mercuryLabel}
- Venus: ${venusLabel}
- Mars: ${marsLabel}
- Moon phase: ${natalChart.moonPhase}
- Birth date: ${birthProfile.birth_date}
- Birth place: ${birthProfile.birth_city}, ${birthProfile.birth_country}
${birthProfile.birth_time ? `- Birth time: ${birthProfile.birth_time}` : ''}

Based on this natal chart data, prepare a detailed and personalized report.`;

    const systemPrompt = locale === 'tr' ? SYSTEM_PROMPT_TR : SYSTEM_PROMPT_EN;

    const messages: LLMMessage[] = [
      { role: 'system', content: wrapPromptForJSON(systemPrompt, ASTRO_REPORT_JSON_SCHEMA) },
      { role: 'user', content: userPrompt },
    ];

    // Call LLM
    const llmProvider = getLLMProviderFromEnv();
    const llmResponse = await llmProvider.generateCompletion(messages, {
      maxTokens: 3000,
      temperature: 0.7,
    });

    // Validate output
    const outputValidation = validateOutput(llmResponse.content);
    if (!outputValidation.valid) {
      logSecurityIssue(user.id, 'astro_report_output', outputValidation.issues, llmResponse.content);
    }

    // Parse output
    const parsedOutput = parseAstroReportOutput(llmResponse.content);
    if (!parsedOutput) {
      return errorResponse('Failed to generate report. Please try again.', 500, 'parse_error');
    }

    // Calculate valid_until for periodic reports
    let validUntil: string | null = null;
    const today = new Date();
    if (reportType === 'weekly') {
      const nextWeek = new Date(today);
      nextWeek.setDate(today.getDate() + 7);
      validUntil = nextWeek.toISOString().split('T')[0];
    } else if (reportType === 'monthly') {
      const nextMonth = new Date(today);
      nextMonth.setMonth(today.getMonth() + 1);
      validUntil = nextMonth.toISOString().split('T')[0];
    } else if (reportType === 'yearly') {
      const nextYear = new Date(today);
      nextYear.setFullYear(today.getFullYear() + 1);
      validUntil = nextYear.toISOString().split('T')[0];
    }

    // Merge chart data
    const finalChartJson = { ...chartJson, ...parsedOutput.chart_json };

    // Store report
    const { data: report, error: insertError } = await serviceClient
      .from('astro_reports')
      .insert({
        user_id: user.id,
        report_type: reportType,
        chart_json: finalChartJson,
        report_text: parsedOutput.report_text,
        sections: parsedOutput.sections,
        status: 'completed',
        valid_until: validUntil,
      })
      .select('id')
      .single();

    if (insertError) {
      console.error('Error storing report:', insertError);
    }

    // Increment usage
    await incrementUsage(supabaseUrl, supabaseServiceKey, user.id, 'astro_report');

    return jsonResponse({
      report_id: report?.id,
      report_type: reportType,
      zodiac_sign: zodiacSign,
      zodiac_label: zodiacLabel,
      chart_json: finalChartJson,
      report_text: parsedOutput.report_text,
      sections: parsedOutput.sections,
      valid_until: validUntil,
      cached: false,
      remaining_today: rateLimit.remaining - 1,
      safety_note:
        locale === 'tr'
          ? 'Bu rapor eğlence amaçlıdır ve profesyonel tavsiye yerine geçmez.'
          : 'This report is for entertainment purposes and does not replace professional advice.',
    });
  } catch (error) {
    console.error('Astro report error:', error);
    return errorResponse(
      error instanceof Error ? error.message : 'Internal server error',
      500,
      'server_error'
    );
  }
});
