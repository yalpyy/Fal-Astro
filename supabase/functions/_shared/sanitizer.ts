/**
 * Input Sanitization and Prompt Injection Prevention
 */

// Dangerous patterns that might indicate prompt injection
const INJECTION_PATTERNS = [
  /ignore\s+(previous|all|above)\s+instructions/i,
  /disregard\s+(previous|all|above)/i,
  /forget\s+(everything|all|previous)/i,
  /you\s+are\s+now/i,
  /new\s+instructions?:/i,
  /system\s*:/i,
  /\[INST\]/i,
  /\[\/INST\]/i,
  /<\|im_start\|>/i,
  /<\|im_end\|>/i,
  /###\s*(system|user|assistant)/i,
  /\bDAN\b/i,
  /jailbreak/i,
  /bypass\s+filter/i,
  /pretend\s+to\s+be/i,
  /act\s+as\s+if/i,
  /roleplay\s+as/i,
];

// Content that should not appear in fortune/astro outputs
const FORBIDDEN_OUTPUT_PATTERNS = [
  /you\s+(will|are\s+going\s+to)\s+die/i,
  /death\s+is\s+(near|coming|imminent)/i,
  /terminal\s+(illness|disease)/i,
  /suicide/i,
  /kill\s+yourself/i,
  /invest\s+all\s+your\s+money/i,
  /buy\s+(stocks?|crypto|bitcoin)/i,
  /sell\s+everything/i,
  /guaranteed\s+(profit|return)/i,
  /medical\s+diagnosis/i,
  /stop\s+taking\s+(medication|medicine)/i,
  /lawyer\s+immediately/i,
  /100%\s+(certain|sure|guaranteed)/i,
  /kesinlikle\s+olacak/i, // Turkish: "definitely will happen"
  /mutlaka\s+ölecek/i, // Turkish: "definitely will die"
  /hastalık\s+kapacak/i, // Turkish: "will catch illness"
];

export interface SanitizeResult {
  sanitized: string;
  wasModified: boolean;
  detectedIssues: string[];
}

/**
 * Sanitize user input to prevent prompt injection
 */
export function sanitizeUserInput(input: string): SanitizeResult {
  const detectedIssues: string[] = [];
  let sanitized = input;
  let wasModified = false;

  // Check for injection patterns
  for (const pattern of INJECTION_PATTERNS) {
    if (pattern.test(sanitized)) {
      detectedIssues.push(`Potential injection pattern detected: ${pattern.source}`);
      // Don't remove, but flag for logging
    }
  }

  // Remove control characters
  const controlCharPattern = /[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g;
  if (controlCharPattern.test(sanitized)) {
    sanitized = sanitized.replace(controlCharPattern, '');
    wasModified = true;
    detectedIssues.push('Control characters removed');
  }

  // Limit length
  const MAX_INPUT_LENGTH = 1000;
  if (sanitized.length > MAX_INPUT_LENGTH) {
    sanitized = sanitized.substring(0, MAX_INPUT_LENGTH);
    wasModified = true;
    detectedIssues.push('Input truncated to max length');
  }

  // Remove excessive whitespace
  const excessiveWhitespace = /\s{10,}/g;
  if (excessiveWhitespace.test(sanitized)) {
    sanitized = sanitized.replace(excessiveWhitespace, ' ');
    wasModified = true;
  }

  // Escape any markdown-like formatting that might confuse the model
  sanitized = sanitized
    .replace(/```/g, '\'\'\'')
    .replace(/\*\*\*/g, '')
    .replace(/###/g, '');

  if (sanitized !== input) {
    wasModified = true;
  }

  return {
    sanitized: sanitized.trim(),
    wasModified,
    detectedIssues,
  };
}

/**
 * Validate LLM output doesn't contain forbidden content
 */
export function validateOutput(output: string): { valid: boolean; issues: string[] } {
  const issues: string[] = [];

  for (const pattern of FORBIDDEN_OUTPUT_PATTERNS) {
    if (pattern.test(output)) {
      issues.push(`Forbidden content detected: ${pattern.source}`);
    }
  }

  return {
    valid: issues.length === 0,
    issues,
  };
}

/**
 * Clean output if it contains minor issues (optional, for logging)
 */
export function sanitizeOutput(output: string): string {
  // Replace absolute certainty with softer language
  let cleaned = output
    .replace(/kesinlikle olacak/gi, 'olabilir')
    .replace(/mutlaka/gi, 'muhtemelen')
    .replace(/100%/g, 'büyük olasılıkla')
    .replace(/guaranteed/gi, 'likely')
    .replace(/definitely will/gi, 'may');

  return cleaned;
}

/**
 * Validate intent value
 */
export function validateIntent(intent: string): boolean {
  const validIntents = ['love', 'money', 'career', 'general', 'aşk', 'para', 'kariyer', 'genel'];
  return validIntents.includes(intent.toLowerCase());
}

/**
 * Validate locale value
 */
export function validateLocale(locale: string): boolean {
  const validLocales = ['tr', 'en'];
  return validLocales.includes(locale.toLowerCase());
}

/**
 * Validate report type
 */
export function validateReportType(reportType: string): boolean {
  const validTypes = ['natal', 'weekly', 'monthly', 'yearly', 'love', 'career'];
  return validTypes.includes(reportType.toLowerCase());
}

/**
 * Log potential security issues (integrate with your logging service)
 */
export function logSecurityIssue(
  userId: string,
  functionName: string,
  issues: string[],
  input: string
): void {
  console.warn('Security issue detected:', {
    userId,
    functionName,
    issues,
    inputPreview: input.substring(0, 100),
    timestamp: new Date().toISOString(),
  });
}
