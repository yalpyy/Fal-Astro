-- ============================================================================
-- FAL & ASTRO - Initial Database Schema
-- Migration: 20240101000000_initial_schema.sql
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc', NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TABLES
-- ============================================================================

-- Profiles table (extends auth.users)
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT,
    avatar_url TEXT,
    locale TEXT DEFAULT 'tr' CHECK (locale IN ('tr', 'en')),
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

COMMENT ON TABLE public.profiles IS 'User profiles extending auth.users';

-- Birth profiles table
CREATE TABLE public.birth_profiles (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    birth_date DATE NOT NULL,
    birth_time TIME, -- Nullable: user might not know exact time
    birth_city TEXT NOT NULL,
    birth_country TEXT NOT NULL,
    timezone TEXT NOT NULL DEFAULT 'Europe/Istanbul',
    unknown_time BOOLEAN DEFAULT FALSE,
    latitude DECIMAL(10, 8), -- For precise astro calculations
    longitude DECIMAL(11, 8),
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

COMMENT ON TABLE public.birth_profiles IS 'Birth information for astrology calculations';

-- Fortune readings table
CREATE TABLE public.fortune_readings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    intent TEXT NOT NULL CHECK (intent IN ('love', 'money', 'career', 'general')),
    cup_image_path TEXT NOT NULL,
    saucer_image_path TEXT, -- Optional
    result_text TEXT,
    symbols JSONB DEFAULT '[]'::jsonb,
    -- Expected format: [{"name": "road", "meaning": "...", "confidence": 0.85}]
    timelines JSONB DEFAULT '{}'::jsonb,
    -- Expected format: {"near": "7 gün...", "mid": "1 ay...", "far": "3 ay..."}
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
    error_message TEXT,
    processing_time_ms INTEGER,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

COMMENT ON TABLE public.fortune_readings IS 'Coffee fortune reading records';

-- Fortune feedback table (for "Tuttu mu?" feature)
CREATE TABLE public.fortune_feedback (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reading_id UUID NOT NULL REFERENCES public.fortune_readings(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    is_accurate BOOLEAN NOT NULL,
    accuracy_rating INTEGER CHECK (accuracy_rating BETWEEN 1 AND 5),
    note TEXT,
    feedback_date TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    UNIQUE(reading_id) -- One feedback per reading
);

COMMENT ON TABLE public.fortune_feedback IS 'User feedback on fortune reading accuracy';

-- Astro reports table
CREATE TABLE public.astro_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    report_type TEXT NOT NULL CHECK (report_type IN ('natal', 'weekly', 'monthly', 'yearly', 'love', 'career')),
    chart_json JSONB DEFAULT '{}'::jsonb,
    -- Expected: {"sun": "aries", "moon": "taurus", "ascendant": "gemini", ...}
    report_text TEXT,
    sections JSONB DEFAULT '{}'::jsonb,
    -- Expected: {"personality": "...", "love": "...", "career": "...", "this_month": "..."}
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
    valid_until DATE, -- For weekly/monthly reports
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

COMMENT ON TABLE public.astro_reports IS 'Generated astrology reports';

-- Daily astro cache table
CREATE TABLE public.daily_astro_cache (
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    zodiac_sign TEXT NOT NULL,
    content TEXT NOT NULL,
    mood_score INTEGER CHECK (mood_score BETWEEN 1 AND 10),
    lucky_numbers INTEGER[],
    lucky_color TEXT,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    PRIMARY KEY (user_id, date)
);

COMMENT ON TABLE public.daily_astro_cache IS 'Cached daily horoscope per user';

-- Subscriptions table
CREATE TABLE public.subscriptions (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    provider TEXT NOT NULL CHECK (provider IN ('apple', 'google', 'manual')),
    product_id TEXT,
    status TEXT NOT NULL DEFAULT 'inactive' CHECK (status IN ('active', 'inactive', 'cancelled', 'expired', 'trial')),
    tier TEXT DEFAULT 'free' CHECK (tier IN ('free', 'premium', 'premium_plus')),
    starts_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    trial_ends_at TIMESTAMPTZ,
    receipt_data TEXT, -- Encrypted store receipt
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

COMMENT ON TABLE public.subscriptions IS 'User subscription and premium status';

-- Usage limits table (for rate limiting)
CREATE TABLE public.usage_limits (
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    fortune_count INTEGER DEFAULT 0,
    astro_report_count INTEGER DEFAULT 0,
    daily_astro_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    PRIMARY KEY (user_id, date)
);

COMMENT ON TABLE public.usage_limits IS 'Daily usage tracking for rate limiting';

-- Pending feedback reminders (for 7-day feedback prompt)
CREATE TABLE public.feedback_reminders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reading_id UUID NOT NULL REFERENCES public.fortune_readings(id) ON DELETE CASCADE,
    remind_at TIMESTAMPTZ NOT NULL,
    reminded BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    UNIQUE(reading_id)
);

COMMENT ON TABLE public.feedback_reminders IS 'Schedule for fortune feedback reminders';

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Profiles
CREATE INDEX idx_profiles_created_at ON public.profiles(created_at DESC);

-- Birth profiles
CREATE INDEX idx_birth_profiles_birth_date ON public.birth_profiles(birth_date);

-- Fortune readings
CREATE INDEX idx_fortune_readings_user_id ON public.fortune_readings(user_id);
CREATE INDEX idx_fortune_readings_created_at ON public.fortune_readings(created_at DESC);
CREATE INDEX idx_fortune_readings_user_created ON public.fortune_readings(user_id, created_at DESC);
CREATE INDEX idx_fortune_readings_status ON public.fortune_readings(status) WHERE status = 'pending';

-- Fortune feedback
CREATE INDEX idx_fortune_feedback_user_id ON public.fortune_feedback(user_id);
CREATE INDEX idx_fortune_feedback_reading_id ON public.fortune_feedback(reading_id);

-- Astro reports
CREATE INDEX idx_astro_reports_user_id ON public.astro_reports(user_id);
CREATE INDEX idx_astro_reports_user_type ON public.astro_reports(user_id, report_type);
CREATE INDEX idx_astro_reports_created_at ON public.astro_reports(created_at DESC);

-- Daily astro cache
CREATE INDEX idx_daily_astro_cache_date ON public.daily_astro_cache(date);

-- Subscriptions
CREATE INDEX idx_subscriptions_status ON public.subscriptions(status) WHERE status = 'active';
CREATE INDEX idx_subscriptions_expires_at ON public.subscriptions(expires_at);

-- Usage limits
CREATE INDEX idx_usage_limits_date ON public.usage_limits(date);

-- Feedback reminders
CREATE INDEX idx_feedback_reminders_remind_at ON public.feedback_reminders(remind_at) WHERE reminded = FALSE;
CREATE INDEX idx_feedback_reminders_user_id ON public.feedback_reminders(user_id);

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Auto-update updated_at for all tables with that column
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_birth_profiles_updated_at
    BEFORE UPDATE ON public.birth_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_fortune_readings_updated_at
    BEFORE UPDATE ON public.fortune_readings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_astro_reports_updated_at
    BEFORE UPDATE ON public.astro_reports
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscriptions_updated_at
    BEFORE UPDATE ON public.subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_usage_limits_updated_at
    BEFORE UPDATE ON public.usage_limits
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- TRIGGER: Auto-create profile on user signup
-- ============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, name)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', '')
    );

    -- Initialize subscription with free tier
    INSERT INTO public.subscriptions (user_id, provider, status, tier)
    VALUES (NEW.id, 'manual', 'active', 'free');

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================================
-- TRIGGER: Auto-create feedback reminder 7 days after fortune reading
-- ============================================================================

CREATE OR REPLACE FUNCTION public.create_feedback_reminder()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        INSERT INTO public.feedback_reminders (user_id, reading_id, remind_at)
        VALUES (NEW.user_id, NEW.id, NEW.updated_at + INTERVAL '7 days')
        ON CONFLICT (reading_id) DO NOTHING;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_fortune_completed
    AFTER UPDATE ON public.fortune_readings
    FOR EACH ROW EXECUTE FUNCTION public.create_feedback_reminder();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.birth_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fortune_readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fortune_feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.astro_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_astro_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.usage_limits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedback_reminders ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- RLS POLICIES: profiles
-- ============================================================================

CREATE POLICY "Users can view own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can delete own profile"
    ON public.profiles FOR DELETE
    USING (auth.uid() = id);

-- ============================================================================
-- RLS POLICIES: birth_profiles
-- ============================================================================

CREATE POLICY "Users can view own birth profile"
    ON public.birth_profiles FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own birth profile"
    ON public.birth_profiles FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own birth profile"
    ON public.birth_profiles FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own birth profile"
    ON public.birth_profiles FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================================================
-- RLS POLICIES: fortune_readings
-- ============================================================================

CREATE POLICY "Users can view own fortune readings"
    ON public.fortune_readings FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own fortune readings"
    ON public.fortune_readings FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own fortune readings"
    ON public.fortune_readings FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own fortune readings"
    ON public.fortune_readings FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================================================
-- RLS POLICIES: fortune_feedback
-- ============================================================================

CREATE POLICY "Users can view own feedback"
    ON public.fortune_feedback FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own feedback"
    ON public.fortune_feedback FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own feedback"
    ON public.fortune_feedback FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own feedback"
    ON public.fortune_feedback FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================================================
-- RLS POLICIES: astro_reports
-- ============================================================================

CREATE POLICY "Users can view own astro reports"
    ON public.astro_reports FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own astro reports"
    ON public.astro_reports FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own astro reports"
    ON public.astro_reports FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own astro reports"
    ON public.astro_reports FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================================================
-- RLS POLICIES: daily_astro_cache
-- ============================================================================

CREATE POLICY "Users can view own daily astro"
    ON public.daily_astro_cache FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own daily astro"
    ON public.daily_astro_cache FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- RLS POLICIES: subscriptions
-- ============================================================================

CREATE POLICY "Users can view own subscription"
    ON public.subscriptions FOR SELECT
    USING (auth.uid() = user_id);

-- Note: INSERT/UPDATE for subscriptions should be done via service role
-- to prevent users from modifying their own subscription status

-- ============================================================================
-- RLS POLICIES: usage_limits
-- ============================================================================

CREATE POLICY "Users can view own usage"
    ON public.usage_limits FOR SELECT
    USING (auth.uid() = user_id);

-- Note: INSERT/UPDATE via service role only

-- ============================================================================
-- RLS POLICIES: feedback_reminders
-- ============================================================================

CREATE POLICY "Users can view own reminders"
    ON public.feedback_reminders FOR SELECT
    USING (auth.uid() = user_id);

-- ============================================================================
-- STORAGE BUCKET SETUP
-- ============================================================================

-- Note: Run these via Supabase Dashboard or supabase CLI
-- INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
-- VALUES (
--     'fortune-images',
--     'fortune-images',
--     false,
--     5242880, -- 5MB
--     ARRAY['image/jpeg', 'image/png', 'image/webp']
-- );

-- ============================================================================
-- STORAGE RLS POLICIES
-- ============================================================================

-- Policy: Users can upload to their own folder
-- Path format: {user_id}/{reading_id}/{filename}

-- SELECT policy
CREATE POLICY "Users can view own fortune images"
    ON storage.objects FOR SELECT
    USING (
        bucket_id = 'fortune-images'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- INSERT policy
CREATE POLICY "Users can upload own fortune images"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'fortune-images'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- UPDATE policy
CREATE POLICY "Users can update own fortune images"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'fortune-images'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- DELETE policy
CREATE POLICY "Users can delete own fortune images"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'fortune-images'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- ============================================================================
-- HELPER FUNCTIONS FOR EDGE FUNCTIONS
-- ============================================================================

-- Function to check if user is premium
CREATE OR REPLACE FUNCTION public.is_user_premium(p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_status TEXT;
    v_expires_at TIMESTAMPTZ;
BEGIN
    SELECT status, expires_at INTO v_status, v_expires_at
    FROM public.subscriptions
    WHERE user_id = p_user_id;

    IF v_status IS NULL THEN
        RETURN FALSE;
    END IF;

    IF v_status = 'active' AND (v_expires_at IS NULL OR v_expires_at > NOW()) THEN
        RETURN TRUE;
    END IF;

    RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get daily usage count
CREATE OR REPLACE FUNCTION public.get_daily_usage(p_user_id UUID, p_type TEXT)
RETURNS INTEGER AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT
        CASE p_type
            WHEN 'fortune' THEN fortune_count
            WHEN 'astro_report' THEN astro_report_count
            WHEN 'daily_astro' THEN daily_astro_count
            ELSE 0
        END INTO v_count
    FROM public.usage_limits
    WHERE user_id = p_user_id AND date = CURRENT_DATE;

    RETURN COALESCE(v_count, 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to increment usage
CREATE OR REPLACE FUNCTION public.increment_usage(p_user_id UUID, p_type TEXT)
RETURNS VOID AS $$
BEGIN
    INSERT INTO public.usage_limits (user_id, date, fortune_count, astro_report_count, daily_astro_count)
    VALUES (p_user_id, CURRENT_DATE, 0, 0, 0)
    ON CONFLICT (user_id, date) DO NOTHING;

    UPDATE public.usage_limits
    SET
        fortune_count = CASE WHEN p_type = 'fortune' THEN fortune_count + 1 ELSE fortune_count END,
        astro_report_count = CASE WHEN p_type = 'astro_report' THEN astro_report_count + 1 ELSE astro_report_count END,
        daily_astro_count = CASE WHEN p_type = 'daily_astro' THEN daily_astro_count + 1 ELSE daily_astro_count END
    WHERE user_id = p_user_id AND date = CURRENT_DATE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get zodiac sign from birth date
CREATE OR REPLACE FUNCTION public.get_zodiac_sign(p_birth_date DATE)
RETURNS TEXT AS $$
DECLARE
    v_month INTEGER;
    v_day INTEGER;
BEGIN
    v_month := EXTRACT(MONTH FROM p_birth_date);
    v_day := EXTRACT(DAY FROM p_birth_date);

    RETURN CASE
        WHEN (v_month = 3 AND v_day >= 21) OR (v_month = 4 AND v_day <= 19) THEN 'aries'
        WHEN (v_month = 4 AND v_day >= 20) OR (v_month = 5 AND v_day <= 20) THEN 'taurus'
        WHEN (v_month = 5 AND v_day >= 21) OR (v_month = 6 AND v_day <= 20) THEN 'gemini'
        WHEN (v_month = 6 AND v_day >= 21) OR (v_month = 7 AND v_day <= 22) THEN 'cancer'
        WHEN (v_month = 7 AND v_day >= 23) OR (v_month = 8 AND v_day <= 22) THEN 'leo'
        WHEN (v_month = 8 AND v_day >= 23) OR (v_month = 9 AND v_day <= 22) THEN 'virgo'
        WHEN (v_month = 9 AND v_day >= 23) OR (v_month = 10 AND v_day <= 22) THEN 'libra'
        WHEN (v_month = 10 AND v_day >= 23) OR (v_month = 11 AND v_day <= 21) THEN 'scorpio'
        WHEN (v_month = 11 AND v_day >= 22) OR (v_month = 12 AND v_day <= 21) THEN 'sagittarius'
        WHEN (v_month = 12 AND v_day >= 22) OR (v_month = 1 AND v_day <= 19) THEN 'capricorn'
        WHEN (v_month = 1 AND v_day >= 20) OR (v_month = 2 AND v_day <= 18) THEN 'aquarius'
        ELSE 'pisces'
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
