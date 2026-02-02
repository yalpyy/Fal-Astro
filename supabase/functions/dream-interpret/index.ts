/**
 * Dream Interpretation Edge Function
 * Analyzes user dreams and provides mystical interpretations
 * Supports both text input and voice transcription
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { handleCors, jsonResponse, errorResponse } from '../_shared/cors.ts';
import { getLLMProviderFromEnv, LLMMessage } from '../_shared/llm_provider.ts';
import { checkRateLimit, incrementUsage, rateLimitError } from '../_shared/rate_limiter.ts';
import { validateOutput, sanitizeInput, logSecurityIssue } from '../_shared/sanitizer.ts';

const SYSTEM_PROMPT_TR = `Sen deneyimli bir rüya yorumcususun. Rüyaları analiz ederek derin ve anlamlı yorumlar yapıyorsun.

GÖREVLER:
1. Rüyadaki sembolleri tespit et
2. Her sembolün olası anlamlarını açıkla
3. Rüyanın genel mesajını yorumla
4. Olumlu ve yapıcı tavsiyeler ver

KURALLAR:
- Pozitif ve umut verici ol
- Korkutucu yorumlardan kaçın
- Tıbbi/psikolojik tavsiye verme
- Bu yorumların eğlence amaçlı olduğunu belirt
- Türkçe yanıt ver

JSON formatında yanıt ver:
{
  "interpretation": "Genel rüya yorumu (3-5 paragraf)",
  "symbols": [
    {"symbol": "sembol adı", "meaning": "anlamı", "context": "rüyadaki bağlamı"}
  ],
  "emotions": ["tespit edilen duygular"],
  "themes": ["ana temalar"],
  "advice": "Tavsiye ve rehberlik",
  "lucky_numbers": [3 şanslı sayı],
  "mood_score": 1-10 arası pozitiflik skoru
}`;

const SYSTEM_PROMPT_EN = `You are an experienced dream interpreter. You analyze dreams and provide deep, meaningful interpretations.

TASKS:
1. Identify symbols in the dream
2. Explain possible meanings of each symbol
3. Interpret the overall message of the dream
4. Provide positive and constructive advice

RULES:
- Be positive and hopeful
- Avoid scary interpretations
- Don't give medical/psychological advice
- Note this is for entertainment
- Respond in English

Respond in JSON format:
{
  "interpretation": "General dream interpretation (3-5 paragraphs)",
  "symbols": [
    {"symbol": "symbol name", "meaning": "its meaning", "context": "context in dream"}
  ],
  "emotions": ["detected emotions"],
  "themes": ["main themes"],
  "advice": "Advice and guidance",
  "lucky_numbers": [3 lucky numbers],
  "mood_score": positivity score 1-10
}`;

interface DreamRequest {
  dream_text: string;
  is_voice_input?: boolean;
  locale?: string;
}

interface DreamSymbol {
  symbol: string;
  meaning: string;
  context?: string;
}

interface DreamInterpretation {
  interpretation: string;
  symbols: DreamSymbol[];
  emotions: string[];
  themes: string[];
  advice: string;
  lucky_numbers: number[];
  mood_score: number;
}

serve(async (req: Request) => {
  const startTime = Date.now();

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
    const body: DreamRequest = await req.json();

    if (!body.dream_text || body.dream_text.trim().length < 10) {
      return errorResponse('Dream text must be at least 10 characters', 400, 'validation_error');
    }

    if (body.dream_text.length > 5000) {
      return errorResponse('Dream text too long (max 5000 characters)', 400, 'validation_error');
    }

    const locale = body.locale?.toLowerCase() === 'en' ? 'en' : 'tr';
    const isVoiceInput = body.is_voice_input || false;

    // Sanitize input
    const sanitizedDream = sanitizeInput(body.dream_text);
    if (!sanitizedDream) {
      return errorResponse('Invalid dream text', 400, 'validation_error');
    }

    // Check rate limit
    const rateLimit = await checkRateLimit(supabaseUrl, supabaseServiceKey, user.id, 'dream');
    if (!rateLimit.allowed) {
      return rateLimitError(rateLimit, 'dream interpretation');
    }

    // Check credits
    const serviceClient = createClient(supabaseUrl, supabaseServiceKey);

    const { data: profile } = await serviceClient
      .from('profiles')
      .select('credits')
      .eq('user_id', user.id)
      .single();

    // Get credit cost from config
    const { data: costConfig } = await serviceClient
      .from('app_config')
      .select('value')
      .eq('key', 'credit_costs')
      .single();

    const creditCosts = costConfig?.value || { dream: 1 };
    const dreamCost = creditCosts.dream || 1;

    if ((profile?.credits || 0) < dreamCost) {
      return errorResponse(
        `Insufficient credits. Dream interpretation costs ${dreamCost} credit(s).`,
        402,
        'insufficient_credits'
      );
    }

    // Create dream record (pending status)
    const { data: dream, error: insertError } = await serviceClient
      .from('dreams')
      .insert({
        user_id: user.id,
        dream_text: sanitizedDream,
        is_voice_input: isVoiceInput,
        status: 'processing',
        locale: locale,
      })
      .select('id')
      .single();

    if (insertError) {
      console.error('Failed to create dream record:', insertError);
      return errorResponse('Failed to save dream', 500, 'db_error');
    }

    // Prepare prompt
    const systemPrompt = locale === 'tr' ? SYSTEM_PROMPT_TR : SYSTEM_PROMPT_EN;
    const userPrompt = locale === 'tr'
      ? `Şu rüyayı yorumla:\n\n"${sanitizedDream}"`
      : `Interpret this dream:\n\n"${sanitizedDream}"`;

    const messages: LLMMessage[] = [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt },
    ];

    // Call LLM
    const llmProvider = getLLMProviderFromEnv();
    const llmResponse = await llmProvider.generateCompletion(messages, {
      maxTokens: 2500,
      temperature: 0.7,
    });

    // Validate output
    const outputValidation = validateOutput(llmResponse.content);
    if (!outputValidation.valid) {
      logSecurityIssue(user.id, 'dream_output', outputValidation.issues, llmResponse.content);
    }

    // Parse response
    let interpretation: DreamInterpretation;
    try {
      const jsonMatch = llmResponse.content.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        throw new Error('No JSON found in response');
      }
      interpretation = JSON.parse(jsonMatch[0]);
    } catch (parseError) {
      console.error('Failed to parse LLM response:', parseError);

      // Update dream with error
      await serviceClient
        .from('dreams')
        .update({
          status: 'failed',
          error_message: 'Failed to parse interpretation',
        })
        .eq('id', dream.id);

      return errorResponse('Failed to interpret dream. Please try again.', 500, 'parse_error');
    }

    const processingTime = Date.now() - startTime;

    // Update dream record with interpretation
    const { error: updateError } = await serviceClient
      .from('dreams')
      .update({
        interpretation: interpretation.interpretation,
        symbols: interpretation.symbols,
        emotions: interpretation.emotions,
        themes: interpretation.themes,
        lucky_numbers: interpretation.lucky_numbers,
        mood_score: interpretation.mood_score,
        processing_time_ms: processingTime,
        status: 'completed',
        completed_at: new Date().toISOString(),
      })
      .eq('id', dream.id);

    if (updateError) {
      console.error('Failed to update dream:', updateError);
    }

    // Deduct credits
    await serviceClient.rpc('deduct_credits', {
      p_user_id: user.id,
      p_amount: dreamCost,
      p_reference_type: 'dream',
      p_reference_id: dream.id,
    });

    // Increment usage for rate limiting
    await incrementUsage(supabaseUrl, supabaseServiceKey, user.id, 'dream');

    // Update user stats
    await serviceClient
      .from('profiles')
      .update({
        total_readings: serviceClient.rpc('increment_total_readings'),
        last_active_date: new Date().toISOString().split('T')[0],
      })
      .eq('user_id', user.id);

    return jsonResponse({
      dream_id: dream.id,
      interpretation: interpretation.interpretation,
      symbols: interpretation.symbols,
      emotions: interpretation.emotions,
      themes: interpretation.themes,
      advice: interpretation.advice,
      lucky_numbers: interpretation.lucky_numbers,
      mood_score: interpretation.mood_score,
      processing_time_ms: processingTime,
      remaining_today: rateLimit.remaining - 1,
      credits_used: dreamCost,
      safety_note: locale === 'tr'
        ? 'Bu yorum eğlence amaçlıdır ve profesyonel psikolojik tavsiye yerine geçmez.'
        : 'This interpretation is for entertainment and does not replace professional psychological advice.',
    });

  } catch (error) {
    console.error('Dream interpretation error:', error);
    return errorResponse(
      error instanceof Error ? error.message : 'Internal server error',
      500,
      'server_error'
    );
  }
});
