/**
 * JSON Schema Validation for LLM Outputs
 * Ensures structured, predictable responses
 */

// Fortune Reading Output Schema
export interface FortuneSymbol {
  name: string;
  meaning: string;
  confidence: number;
}

export interface FortuneTimelines {
  near: string;  // 7 days
  mid: string;   // 1 month
  far: string;   // 3 months
}

export interface FortuneOutput {
  result_text: string;
  timelines: FortuneTimelines;
  symbols: FortuneSymbol[];
  safety_note: string;
}

// Daily Astro Output Schema
export interface DailyAstroOutput {
  content: string;
  mood_score: number;
  lucky_numbers: number[];
  lucky_color: string;
  advice: string;
}

// Astro Report Output Schema
export interface AstroReportOutput {
  chart_json: Record<string, string>;
  report_text: string;
  sections: {
    personality?: string;
    love?: string;
    career?: string;
    this_month?: string;
    this_week?: string;
    this_year?: string;
  };
}

// Compatibility Report Output Schema
export interface CompatReportOutput {
  compatibility_score: number;
  summary: string;
  strengths: string[];
  challenges: string[];
  advice: string;
}

/**
 * Parse and validate fortune output from LLM
 */
export function parseFortuneOutput(raw: string): FortuneOutput | null {
  try {
    // Try to extract JSON from the response
    const jsonMatch = raw.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      console.error('No JSON found in fortune output');
      return null;
    }

    const parsed = JSON.parse(jsonMatch[0]);

    // Validate required fields
    if (!parsed.result_text || typeof parsed.result_text !== 'string') {
      console.error('Missing or invalid result_text');
      return null;
    }

    // Validate timelines
    if (!parsed.timelines || typeof parsed.timelines !== 'object') {
      parsed.timelines = { near: '', mid: '', far: '' };
    }
    parsed.timelines.near = parsed.timelines.near || parsed.timelines.yakin || '';
    parsed.timelines.mid = parsed.timelines.mid || parsed.timelines.orta || '';
    parsed.timelines.far = parsed.timelines.far || parsed.timelines.uzak || '';

    // Validate symbols
    if (!Array.isArray(parsed.symbols)) {
      parsed.symbols = [];
    }
    parsed.symbols = parsed.symbols
      .filter(
        (s: unknown): s is FortuneSymbol =>
          typeof s === 'object' &&
          s !== null &&
          typeof (s as FortuneSymbol).name === 'string' &&
          typeof (s as FortuneSymbol).meaning === 'string'
      )
      .map((s: FortuneSymbol) => ({
        name: s.name,
        meaning: s.meaning,
        confidence: typeof s.confidence === 'number' ? Math.min(1, Math.max(0, s.confidence)) : 0.7,
      }))
      .slice(0, 10); // Max 10 symbols

    // Ensure safety note
    parsed.safety_note =
      parsed.safety_note ||
      'Bu yorum eğlence amaçlıdır ve profesyonel tavsiye yerine geçmez.';

    return {
      result_text: parsed.result_text,
      timelines: parsed.timelines,
      symbols: parsed.symbols,
      safety_note: parsed.safety_note,
    };
  } catch (error) {
    console.error('Error parsing fortune output:', error);
    return null;
  }
}

/**
 * Parse and validate daily astro output from LLM
 */
export function parseDailyAstroOutput(raw: string): DailyAstroOutput | null {
  try {
    const jsonMatch = raw.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      // If no JSON, treat entire response as content
      return {
        content: raw.trim(),
        mood_score: 5,
        lucky_numbers: [7],
        lucky_color: 'mavi',
        advice: '',
      };
    }

    const parsed = JSON.parse(jsonMatch[0]);

    return {
      content: parsed.content || parsed.icerik || raw.trim(),
      mood_score: Math.min(10, Math.max(1, parseInt(parsed.mood_score) || 5)),
      lucky_numbers: Array.isArray(parsed.lucky_numbers)
        ? parsed.lucky_numbers.filter((n: unknown) => typeof n === 'number').slice(0, 3)
        : [7],
      lucky_color: parsed.lucky_color || parsed.sans_rengi || 'mavi',
      advice: parsed.advice || parsed.tavsiye || '',
    };
  } catch {
    return {
      content: raw.trim(),
      mood_score: 5,
      lucky_numbers: [7],
      lucky_color: 'mavi',
      advice: '',
    };
  }
}

/**
 * Parse and validate astro report output from LLM
 */
export function parseAstroReportOutput(raw: string): AstroReportOutput | null {
  try {
    const jsonMatch = raw.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      return {
        chart_json: {},
        report_text: raw.trim(),
        sections: {},
      };
    }

    const parsed = JSON.parse(jsonMatch[0]);

    return {
      chart_json: parsed.chart_json || parsed.harita || {},
      report_text: parsed.report_text || parsed.rapor_metni || '',
      sections: {
        personality: parsed.sections?.personality || parsed.bolumler?.kisilik,
        love: parsed.sections?.love || parsed.bolumler?.ask,
        career: parsed.sections?.career || parsed.bolumler?.kariyer,
        this_month: parsed.sections?.this_month || parsed.bolumler?.bu_ay,
        this_week: parsed.sections?.this_week || parsed.bolumler?.bu_hafta,
        this_year: parsed.sections?.this_year || parsed.bolumler?.bu_yil,
      },
    };
  } catch {
    return {
      chart_json: {},
      report_text: raw.trim(),
      sections: {},
    };
  }
}

/**
 * Parse and validate compatibility report output from LLM
 */
export function parseCompatReportOutput(raw: string): CompatReportOutput | null {
  try {
    const jsonMatch = raw.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      return null;
    }

    const parsed = JSON.parse(jsonMatch[0]);

    return {
      compatibility_score: Math.min(100, Math.max(0, parseInt(parsed.compatibility_score) || 50)),
      summary: parsed.summary || parsed.ozet || '',
      strengths: Array.isArray(parsed.strengths) ? parsed.strengths : [],
      challenges: Array.isArray(parsed.challenges) ? parsed.challenges : [],
      advice: parsed.advice || parsed.tavsiye || '',
    };
  } catch {
    return null;
  }
}

/**
 * Create a structured prompt that guides LLM to return proper JSON
 */
export function wrapPromptForJSON(prompt: string, schema: string): string {
  return `${prompt}

IMPORTANT: Your response MUST be a valid JSON object following this exact structure:
${schema}

Respond ONLY with the JSON object, no additional text before or after.`;
}

// Schema templates for prompts
export const FORTUNE_JSON_SCHEMA = `{
  "result_text": "Ana yorum metni (2-3 paragraf)",
  "timelines": {
    "near": "7 gün içinde...",
    "mid": "1 ay içinde...",
    "far": "3 ay içinde..."
  },
  "symbols": [
    {"name": "sembol_adı", "meaning": "sembol açıklaması", "confidence": 0.85}
  ],
  "safety_note": "Eğlence amaçlı uyarı"
}`;

export const DAILY_ASTRO_JSON_SCHEMA = `{
  "content": "Günlük yorum metni",
  "mood_score": 7,
  "lucky_numbers": [3, 7, 21],
  "lucky_color": "mavi",
  "advice": "Günlük tavsiye"
}`;

export const ASTRO_REPORT_JSON_SCHEMA = `{
  "chart_json": {"sun": "aries", "moon": "taurus", ...},
  "report_text": "Genel rapor metni",
  "sections": {
    "personality": "Kişilik analizi",
    "love": "Aşk yorumu",
    "career": "Kariyer yorumu",
    "this_month": "Bu ay yorumu"
  }
}`;

export const COMPAT_REPORT_JSON_SCHEMA = `{
  "compatibility_score": 75,
  "summary": "Genel uyum özeti",
  "strengths": ["Güçlü yön 1", "Güçlü yön 2"],
  "challenges": ["Zorluk 1", "Zorluk 2"],
  "advice": "İlişki tavsiyesi"
}`;
