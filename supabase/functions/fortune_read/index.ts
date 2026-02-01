/**
 * Fortune Read Edge Function
 * Analyzes coffee cup images and generates fortune readings
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { handleCors, jsonResponse, errorResponse } from '../_shared/cors.ts';
import { getLLMProviderFromEnv, LLMMessage } from '../_shared/llm_provider.ts';
import { checkRateLimit, incrementUsage, rateLimitError } from '../_shared/rate_limiter.ts';
import {
  sanitizeUserInput,
  validateIntent,
  validateLocale,
  validateOutput,
  logSecurityIssue,
} from '../_shared/sanitizer.ts';
import {
  parseFortuneOutput,
  wrapPromptForJSON,
  FORTUNE_JSON_SCHEMA,
  FortuneOutput,
} from '../_shared/schema_validator.ts';

// Prompt templates
const FORTUNE_SYSTEM_PROMPT_TR = `Sen deneyimli bir Türk kahve falcısısın. Fincan ve tabak görüntülerini analiz ederek sıcak, umut dolu ve eğlenceli yorumlar yapıyorsun.

KURALLAR:
- Kesinlikle tıbbi, hukuki veya finansal tavsiye verme
- "Kesinlikle olacak", "mutlaka" gibi kesin ifadeler kullanma
- Ölüm, ciddi hastalık, felaket gibi olumsuz kehanetler yapma
- Korku veya endişe yaratacak ifadelerden kaçın
- Sıcak, samimi ve pozitif bir ton kullan
- Her zaman umut ve olumlu yönlendirme sun

YORUM YAPISI:
1. Genel atmosfer ve enerji yorumu
2. 3 zaman dilimi (7 gün, 1 ay, 3 ay)
3. Gördüğün semboller ve anlamları
4. Eğlence amaçlı olduğunu belirten not

Yanıtını JSON formatında ver.`;

const FORTUNE_SYSTEM_PROMPT_EN = `You are an experienced Turkish coffee fortune teller. You analyze cup and saucer images to provide warm, hopeful, and entertaining readings.

RULES:
- Never give medical, legal, or financial advice
- Avoid absolute statements like "will definitely happen"
- No predictions about death, serious illness, or disasters
- Avoid language that creates fear or anxiety
- Use a warm, friendly, and positive tone
- Always offer hope and positive guidance

READING STRUCTURE:
1. General atmosphere and energy
2. 3 time periods (7 days, 1 month, 3 months)
3. Symbols you see and their meanings
4. Disclaimer that this is for entertainment

Respond in JSON format.`;

interface FortuneRequest {
  intent: string;
  cup_image_signed_url: string;
  saucer_image_signed_url?: string;
  locale?: string;
  custom_note?: string;
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

    // Create Supabase client with user's JWT
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
    const body: FortuneRequest = await req.json();

    // Validate inputs
    if (!body.cup_image_signed_url) {
      return errorResponse('cup_image_signed_url is required', 400, 'validation_error');
    }

    if (!body.intent || !validateIntent(body.intent)) {
      return errorResponse('Valid intent is required (love, money, career, general)', 400, 'validation_error');
    }

    const locale = body.locale?.toLowerCase() === 'en' ? 'en' : 'tr';

    // Sanitize custom note if provided
    let customNote = '';
    if (body.custom_note) {
      const sanitized = sanitizeUserInput(body.custom_note);
      customNote = sanitized.sanitized;
      if (sanitized.detectedIssues.length > 0) {
        logSecurityIssue(user.id, 'fortune_read', sanitized.detectedIssues, body.custom_note);
      }
    }

    // Check rate limit
    const rateLimit = await checkRateLimit(supabaseUrl, supabaseServiceKey, user.id, 'fortune');
    if (!rateLimit.allowed) {
      return rateLimitError(rateLimit, 'fortune');
    }

    // Prepare images array
    const imageUrls = [body.cup_image_signed_url];
    if (body.saucer_image_signed_url) {
      imageUrls.push(body.saucer_image_signed_url);
    }

    // Prepare prompt
    const intentLabels: Record<string, Record<string, string>> = {
      tr: { love: 'aşk', money: 'para', career: 'kariyer', general: 'genel' },
      en: { love: 'love', money: 'money', career: 'career', general: 'general' },
    };
    const intentLabel = intentLabels[locale][body.intent] || body.intent;

    const userPrompt =
      locale === 'tr'
        ? `Bu kahve fincanı ${imageUrls.length > 1 ? 've tabak ' : ''}görüntüsünü analiz et.
Danışanın niyeti: ${intentLabel}
${customNote ? `Danışanın notu: ${customNote}` : ''}

Fincanı dikkatle incele ve detaylı bir yorum yap.`
        : `Analyze this coffee cup ${imageUrls.length > 1 ? 'and saucer ' : ''}image.
Querent's intention: ${intentLabel}
${customNote ? `Querent's note: ${customNote}` : ''}

Carefully examine the cup and provide a detailed reading.`;

    const systemPrompt = locale === 'tr' ? FORTUNE_SYSTEM_PROMPT_TR : FORTUNE_SYSTEM_PROMPT_EN;

    const messages: LLMMessage[] = [
      { role: 'system', content: wrapPromptForJSON(systemPrompt, FORTUNE_JSON_SCHEMA) },
      { role: 'user', content: userPrompt },
    ];

    // Call LLM with images
    const startTime = Date.now();
    const llmProvider = getLLMProviderFromEnv();
    const llmResponse = await llmProvider.generateWithImages(messages, imageUrls, {
      maxTokens: 2048,
      temperature: 0.7,
    });
    const processingTime = Date.now() - startTime;

    // Validate output
    const outputValidation = validateOutput(llmResponse.content);
    if (!outputValidation.valid) {
      logSecurityIssue(user.id, 'fortune_read_output', outputValidation.issues, llmResponse.content);
      // Attempt to regenerate or return generic response
      return errorResponse('Unable to generate appropriate reading. Please try again.', 500, 'content_filter');
    }

    // Parse structured output
    const parsedOutput = parseFortuneOutput(llmResponse.content);
    if (!parsedOutput) {
      console.error('Failed to parse fortune output:', llmResponse.content);
      return errorResponse('Failed to parse reading. Please try again.', 500, 'parse_error');
    }

    // Create service client for database operations
    const serviceClient = createClient(supabaseUrl, supabaseServiceKey);

    // Store reading in database
    const { data: reading, error: insertError } = await serviceClient
      .from('fortune_readings')
      .insert({
        user_id: user.id,
        intent: body.intent,
        cup_image_path: extractPathFromUrl(body.cup_image_signed_url),
        saucer_image_path: body.saucer_image_signed_url
          ? extractPathFromUrl(body.saucer_image_signed_url)
          : null,
        result_text: parsedOutput.result_text,
        symbols: parsedOutput.symbols,
        timelines: parsedOutput.timelines,
        status: 'completed',
        processing_time_ms: processingTime,
      })
      .select('id')
      .single();

    if (insertError) {
      console.error('Error storing reading:', insertError);
      // Continue anyway, user should get their reading
    }

    // Increment usage
    await incrementUsage(supabaseUrl, supabaseServiceKey, user.id, 'fortune');

    // Return response
    const response: FortuneOutput & { reading_id?: string; remaining_today: number } = {
      ...parsedOutput,
      reading_id: reading?.id,
      remaining_today: rateLimit.remaining - 1,
    };

    return jsonResponse(response);
  } catch (error) {
    console.error('Fortune read error:', error);
    return errorResponse(
      error instanceof Error ? error.message : 'Internal server error',
      500,
      'server_error'
    );
  }
});

// Helper to extract storage path from signed URL
function extractPathFromUrl(signedUrl: string): string {
  try {
    const url = new URL(signedUrl);
    const pathMatch = url.pathname.match(/\/storage\/v1\/object\/sign\/([^?]+)/);
    if (pathMatch) {
      return decodeURIComponent(pathMatch[1]);
    }
    // Try alternate format
    const altMatch = url.pathname.match(/\/object\/([^?]+)/);
    if (altMatch) {
      return decodeURIComponent(altMatch[1]);
    }
    return signedUrl;
  } catch {
    return signedUrl;
  }
}

