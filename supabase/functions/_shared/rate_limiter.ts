/**
 * Rate Limiting Utilities
 * Handles daily usage limits based on subscription tier
 */

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

export interface UsageLimits {
  fortune: number;
  astroReport: number;
  dailyAstro: number;
}

// Limits per tier
export const TIER_LIMITS: Record<string, UsageLimits> = {
  free: {
    fortune: 1,
    astroReport: 1,
    dailyAstro: 3,
  },
  premium: {
    fortune: 10,
    astroReport: 5,
    dailyAstro: 10,
  },
  premium_plus: {
    fortune: -1, // Unlimited
    astroReport: -1,
    dailyAstro: -1,
  },
};

export type UsageType = 'fortune' | 'astro_report' | 'daily_astro';

interface RateLimitResult {
  allowed: boolean;
  currentUsage: number;
  limit: number;
  remaining: number;
  tier: string;
}

export async function checkRateLimit(
  supabaseUrl: string,
  serviceRoleKey: string,
  userId: string,
  usageType: UsageType
): Promise<RateLimitResult> {
  const supabase = createClient(supabaseUrl, serviceRoleKey);

  // Get user's subscription tier
  const { data: subscription, error: subError } = await supabase
    .from('subscriptions')
    .select('tier, status, expires_at')
    .eq('user_id', userId)
    .single();

  if (subError && subError.code !== 'PGRST116') {
    console.error('Error fetching subscription:', subError);
  }

  // Determine effective tier
  let tier = 'free';
  if (subscription) {
    const isActive =
      subscription.status === 'active' &&
      (!subscription.expires_at || new Date(subscription.expires_at) > new Date());
    if (isActive) {
      tier = subscription.tier || 'free';
    }
  }

  const limits = TIER_LIMITS[tier] || TIER_LIMITS.free;

  // Map usage type to limit key
  const limitKey = usageType === 'fortune' ? 'fortune' : usageType === 'astro_report' ? 'astroReport' : 'dailyAstro';
  const limit = limits[limitKey];

  // Unlimited check
  if (limit === -1) {
    return {
      allowed: true,
      currentUsage: 0,
      limit: -1,
      remaining: -1,
      tier,
    };
  }

  // Get current usage
  const { data: usage, error: usageError } = await supabase
    .rpc('get_daily_usage', { p_user_id: userId, p_type: usageType });

  if (usageError) {
    console.error('Error fetching usage:', usageError);
    // Fail open but log
    return {
      allowed: true,
      currentUsage: 0,
      limit,
      remaining: limit,
      tier,
    };
  }

  const currentUsage = usage || 0;
  const allowed = currentUsage < limit;
  const remaining = Math.max(0, limit - currentUsage);

  return {
    allowed,
    currentUsage,
    limit,
    remaining,
    tier,
  };
}

export async function incrementUsage(
  supabaseUrl: string,
  serviceRoleKey: string,
  userId: string,
  usageType: UsageType
): Promise<void> {
  const supabase = createClient(supabaseUrl, serviceRoleKey);

  const { error } = await supabase.rpc('increment_usage', {
    p_user_id: userId,
    p_type: usageType,
  });

  if (error) {
    console.error('Error incrementing usage:', error);
  }
}

export function rateLimitError(result: RateLimitResult, usageType: string): Response {
  return new Response(
    JSON.stringify({
      error: 'rate_limit_exceeded',
      message: `Daily ${usageType} limit reached`,
      current_usage: result.currentUsage,
      limit: result.limit,
      tier: result.tier,
      upgrade_hint: result.tier === 'free' ? 'Upgrade to premium for more readings' : null,
    }),
    {
      status: 429,
      headers: { 'Content-Type': 'application/json' },
    }
  );
}
