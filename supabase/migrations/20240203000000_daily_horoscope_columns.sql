-- ============================================================================
-- FAL & ASTRO - Daily Horoscope Extended Columns
-- Migration: 20240203000000_daily_horoscope_columns.sql
-- Adds columns for offline horoscope generation with planetary data
-- ============================================================================

-- Add extended columns to daily_affirmations for detailed horoscope data
ALTER TABLE daily_affirmations
ADD COLUMN IF NOT EXISTS love_text TEXT,
ADD COLUMN IF NOT EXISTS career_text TEXT,
ADD COLUMN IF NOT EXISTS health_text TEXT,
ADD COLUMN IF NOT EXISTS overall_score INTEGER CHECK (overall_score >= 1 AND overall_score <= 100),
ADD COLUMN IF NOT EXISTS love_score INTEGER CHECK (love_score >= 1 AND love_score <= 100),
ADD COLUMN IF NOT EXISTS career_score INTEGER CHECK (career_score >= 1 AND career_score <= 100),
ADD COLUMN IF NOT EXISTS health_score INTEGER CHECK (health_score >= 1 AND health_score <= 100),
ADD COLUMN IF NOT EXISTS moon_phase VARCHAR(50),
ADD COLUMN IF NOT EXISTS planetary_influence TEXT,
ADD COLUMN IF NOT EXISTS lucky_numbers INTEGER[],
ADD COLUMN IF NOT EXISTS compatibility_sign VARCHAR(20),
ADD COLUMN IF NOT EXISTS generation_mode VARCHAR(20) DEFAULT 'offline' CHECK (generation_mode IN ('offline', 'llm', 'manual'));

-- Add index for faster queries by generation mode
CREATE INDEX IF NOT EXISTS idx_daily_affirmations_mode ON daily_affirmations(generation_mode);

-- ============================================================================
-- NATAL CHART DATA - Store pre-calculated natal charts for users
-- ============================================================================

-- Natal chart cache table for storing calculated charts
CREATE TABLE IF NOT EXISTS natal_chart_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    calculated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Core positions
    sun_sign VARCHAR(20) NOT NULL,
    sun_degree DECIMAL(10, 6),
    moon_sign VARCHAR(20) NOT NULL,
    moon_degree DECIMAL(10, 6),
    ascendant_sign VARCHAR(20),
    ascendant_degree DECIMAL(10, 6),
    midheaven_sign VARCHAR(20),
    midheaven_degree DECIMAL(10, 6),

    -- Inner planets
    mercury_sign VARCHAR(20),
    mercury_degree DECIMAL(10, 6),
    venus_sign VARCHAR(20),
    venus_degree DECIMAL(10, 6),
    mars_sign VARCHAR(20),
    mars_degree DECIMAL(10, 6),

    -- Social planets
    jupiter_sign VARCHAR(20),
    jupiter_degree DECIMAL(10, 6),
    saturn_sign VARCHAR(20),
    saturn_degree DECIMAL(10, 6),

    -- Outer planets
    uranus_sign VARCHAR(20),
    uranus_degree DECIMAL(10, 6),
    neptune_sign VARCHAR(20),
    neptune_degree DECIMAL(10, 6),
    pluto_sign VARCHAR(20),
    pluto_degree DECIMAL(10, 6),

    -- Houses (Placidus)
    houses DECIMAL(10, 6)[] CHECK (array_length(houses, 1) = 12),

    -- Aspects
    aspects JSONB DEFAULT '[]',
    -- Format: [{"planet1": "Sun", "planet2": "Moon", "aspect": "trine", "orb": 2.5, "exact_degree": 120}]

    -- Analysis
    dominant_element VARCHAR(20), -- fire, earth, air, water
    dominant_modality VARCHAR(20), -- cardinal, fixed, mutable
    stelliums JSONB DEFAULT '[]', -- Signs/houses with 3+ planets

    -- Full chart JSON (for flexibility)
    full_chart_json JSONB DEFAULT '{}',

    -- Metadata
    calculation_version VARCHAR(20) DEFAULT '1.0',

    UNIQUE(user_id)
);

CREATE INDEX IF NOT EXISTS idx_natal_chart_user ON natal_chart_cache(user_id);

-- Enable RLS
ALTER TABLE natal_chart_cache ENABLE ROW LEVEL SECURITY;

-- Users can view their own chart
CREATE POLICY natal_chart_select_own ON natal_chart_cache FOR SELECT
    USING (auth.uid() = user_id);

-- Users can insert their own chart
CREATE POLICY natal_chart_insert_own ON natal_chart_cache FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own chart
CREATE POLICY natal_chart_update_own ON natal_chart_cache FOR UPDATE
    USING (auth.uid() = user_id);

-- ============================================================================
-- PLANETARY TRANSITS - Store current planetary positions
-- ============================================================================

CREATE TABLE IF NOT EXISTS planetary_transits (
    date DATE PRIMARY KEY,
    calculated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Sun through Pluto positions
    sun_degree DECIMAL(10, 6) NOT NULL,
    sun_sign VARCHAR(20) NOT NULL,
    moon_degree DECIMAL(10, 6) NOT NULL,
    moon_sign VARCHAR(20) NOT NULL,
    moon_phase VARCHAR(30), -- new_moon, waxing_crescent, first_quarter, etc.
    mercury_degree DECIMAL(10, 6),
    mercury_sign VARCHAR(20),
    mercury_retrograde BOOLEAN DEFAULT FALSE,
    venus_degree DECIMAL(10, 6),
    venus_sign VARCHAR(20),
    venus_retrograde BOOLEAN DEFAULT FALSE,
    mars_degree DECIMAL(10, 6),
    mars_sign VARCHAR(20),
    mars_retrograde BOOLEAN DEFAULT FALSE,
    jupiter_degree DECIMAL(10, 6),
    jupiter_sign VARCHAR(20),
    jupiter_retrograde BOOLEAN DEFAULT FALSE,
    saturn_degree DECIMAL(10, 6),
    saturn_sign VARCHAR(20),
    saturn_retrograde BOOLEAN DEFAULT FALSE,
    uranus_degree DECIMAL(10, 6),
    uranus_sign VARCHAR(20),
    uranus_retrograde BOOLEAN DEFAULT FALSE,
    neptune_degree DECIMAL(10, 6),
    neptune_sign VARCHAR(20),
    neptune_retrograde BOOLEAN DEFAULT FALSE,
    pluto_degree DECIMAL(10, 6),
    pluto_sign VARCHAR(20),
    pluto_retrograde BOOLEAN DEFAULT FALSE,

    -- Major aspects active today
    major_aspects JSONB DEFAULT '[]',

    -- General energy description
    energy_summary TEXT,

    -- Full data
    full_data JSONB DEFAULT '{}'
);

-- Public read access for transits
ALTER TABLE planetary_transits ENABLE ROW LEVEL SECURITY;

CREATE POLICY planetary_transits_select_all ON planetary_transits FOR SELECT
    USING (TRUE);

-- ============================================================================
-- FUNCTION: Get or calculate natal chart
-- ============================================================================

CREATE OR REPLACE FUNCTION get_user_natal_chart(p_user_id UUID)
RETURNS TABLE (
    sun_sign VARCHAR,
    moon_sign VARCHAR,
    ascendant_sign VARCHAR,
    mercury_sign VARCHAR,
    venus_sign VARCHAR,
    mars_sign VARCHAR,
    jupiter_sign VARCHAR,
    saturn_sign VARCHAR,
    uranus_sign VARCHAR,
    neptune_sign VARCHAR,
    pluto_sign VARCHAR,
    dominant_element VARCHAR,
    dominant_modality VARCHAR,
    aspects JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        nc.sun_sign,
        nc.moon_sign,
        nc.ascendant_sign,
        nc.mercury_sign,
        nc.venus_sign,
        nc.mars_sign,
        nc.jupiter_sign,
        nc.saturn_sign,
        nc.uranus_sign,
        nc.neptune_sign,
        nc.pluto_sign,
        nc.dominant_element,
        nc.dominant_modality,
        nc.aspects
    FROM natal_chart_cache nc
    WHERE nc.user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- FUNCTION: Store natal chart from calculation
-- ============================================================================

CREATE OR REPLACE FUNCTION upsert_natal_chart(
    p_user_id UUID,
    p_chart_data JSONB
)
RETURNS UUID AS $$
DECLARE
    v_chart_id UUID;
BEGIN
    INSERT INTO natal_chart_cache (
        user_id,
        sun_sign, sun_degree,
        moon_sign, moon_degree,
        ascendant_sign, ascendant_degree,
        midheaven_sign, midheaven_degree,
        mercury_sign, mercury_degree,
        venus_sign, venus_degree,
        mars_sign, mars_degree,
        jupiter_sign, jupiter_degree,
        saturn_sign, saturn_degree,
        uranus_sign, uranus_degree,
        neptune_sign, neptune_degree,
        pluto_sign, pluto_degree,
        houses,
        aspects,
        dominant_element,
        dominant_modality,
        full_chart_json,
        calculated_at
    )
    VALUES (
        p_user_id,
        p_chart_data->>'sunSign', (p_chart_data->>'sunDegree')::DECIMAL,
        p_chart_data->>'moonSign', (p_chart_data->>'moonDegree')::DECIMAL,
        p_chart_data->>'ascendantSign', (p_chart_data->>'ascendantDegree')::DECIMAL,
        p_chart_data->>'midheavenSign', (p_chart_data->>'midheavenDegree')::DECIMAL,
        p_chart_data->>'mercurySign', (p_chart_data->>'mercuryDegree')::DECIMAL,
        p_chart_data->>'venusSign', (p_chart_data->>'venusDegree')::DECIMAL,
        p_chart_data->>'marsSign', (p_chart_data->>'marsDegree')::DECIMAL,
        p_chart_data->>'jupiterSign', (p_chart_data->>'jupiterDegree')::DECIMAL,
        p_chart_data->>'saturnSign', (p_chart_data->>'saturnDegree')::DECIMAL,
        p_chart_data->>'uranusSign', (p_chart_data->>'uranusDegree')::DECIMAL,
        p_chart_data->>'neptuneSign', (p_chart_data->>'neptuneDegree')::DECIMAL,
        p_chart_data->>'plutoSign', (p_chart_data->>'plutoDegree')::DECIMAL,
        ARRAY(SELECT jsonb_array_elements_text(p_chart_data->'houses')::DECIMAL),
        p_chart_data->'aspects',
        p_chart_data->>'dominantElement',
        p_chart_data->>'dominantModality',
        p_chart_data,
        NOW()
    )
    ON CONFLICT (user_id) DO UPDATE SET
        sun_sign = EXCLUDED.sun_sign,
        sun_degree = EXCLUDED.sun_degree,
        moon_sign = EXCLUDED.moon_sign,
        moon_degree = EXCLUDED.moon_degree,
        ascendant_sign = EXCLUDED.ascendant_sign,
        ascendant_degree = EXCLUDED.ascendant_degree,
        midheaven_sign = EXCLUDED.midheaven_sign,
        midheaven_degree = EXCLUDED.midheaven_degree,
        mercury_sign = EXCLUDED.mercury_sign,
        mercury_degree = EXCLUDED.mercury_degree,
        venus_sign = EXCLUDED.venus_sign,
        venus_degree = EXCLUDED.venus_degree,
        mars_sign = EXCLUDED.mars_sign,
        mars_degree = EXCLUDED.mars_degree,
        jupiter_sign = EXCLUDED.jupiter_sign,
        jupiter_degree = EXCLUDED.jupiter_degree,
        saturn_sign = EXCLUDED.saturn_sign,
        saturn_degree = EXCLUDED.saturn_degree,
        uranus_sign = EXCLUDED.uranus_sign,
        uranus_degree = EXCLUDED.uranus_degree,
        neptune_sign = EXCLUDED.neptune_sign,
        neptune_degree = EXCLUDED.neptune_degree,
        pluto_sign = EXCLUDED.pluto_sign,
        pluto_degree = EXCLUDED.pluto_degree,
        houses = EXCLUDED.houses,
        aspects = EXCLUDED.aspects,
        dominant_element = EXCLUDED.dominant_element,
        dominant_modality = EXCLUDED.dominant_modality,
        full_chart_json = EXCLUDED.full_chart_json,
        calculated_at = NOW()
    RETURNING id INTO v_chart_id;

    RETURN v_chart_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION upsert_natal_chart(UUID, JSONB) TO authenticated;

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================
