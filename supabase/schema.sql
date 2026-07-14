-- ═══════════════════════════════════════════════════════
-- 型得你 — Supabase Schema
-- Run this in Supabase SQL Editor after creating project
-- ═══════════════════════════════════════════════════════

-- Users (extends Supabase auth.users)
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  display_name TEXT,
  mbti_type TEXT,
  enneagram_type TEXT,
  birth_date DATE,
  birth_time TIME,
  birth_place TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Daily quotes library
CREATE TABLE public.daily_quotes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quote TEXT NOT NULL,
  source TEXT,
  category TEXT CHECK (category IN ('inspirational', 'movie', 'encouragement', 'zodiac')),
  mbti_type TEXT, -- NULL = general, 'ENFJ' = type-specific (premium)
  is_ai_generated BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Quote schedule (which quote goes to which day)
CREATE TABLE public.quote_schedule (
  date DATE PRIMARY KEY,
  quote_id UUID REFERENCES public.daily_quotes(id),
  delivered_at TIMESTAMPTZ
);

-- Mood logs
CREATE TABLE public.mood_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  mood_emoji TEXT NOT NULL,
  note TEXT,
  logged_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, logged_date)
);

-- Personality assessment results
CREATE TABLE public.assessment_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  assessment_type TEXT CHECK (assessment_type IN ('mbti', 'enneagram', 'scenario', 'sbti')),
  scores JSONB,
  result TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Mental health screening (PHQ-2 / GAD-2)
CREATE TABLE public.mental_health_screenings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  screening_type TEXT CHECK (screening_type IN ('phq2', 'gad2', 'phq9', 'gad7', 'scenario')),
  score INTEGER NOT NULL,
  severity TEXT,
  responses JSONB,
  screened_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Device tokens for push notifications
CREATE TABLE public.user_devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  fcm_token TEXT NOT NULL,
  platform TEXT CHECK (platform IN ('ios', 'android')),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Subscriptions (via RevenueCat webhook)
CREATE TABLE public.subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  revenuecat_id TEXT UNIQUE,
  product_id TEXT,
  entitlement TEXT,
  expires_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ═══════════════════════════════════════════════════════
-- Row Level Security (RLS) — users can only see own data
-- ═══════════════════════════════════════════════════════

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mood_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assessment_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mental_health_screenings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

-- Profiles: user can CRUD own profile
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- Mood logs: user can CRUD own logs
CREATE POLICY "Users can view own mood logs"
  ON public.mood_logs FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own mood logs"
  ON public.mood_logs FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Daily quotes: anyone can read (public content)
CREATE POLICY "Anyone can read quotes"
  ON public.daily_quotes FOR SELECT
  USING (TRUE);

-- ═══════════════════════════════════════════════════════
-- Functions
-- ═══════════════════════════════════════════════════════

-- Get today's quote (random if not scheduled)
CREATE OR REPLACE FUNCTION get_daily_quote()
RETURNS TABLE (id UUID, quote TEXT, source TEXT, category TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT q.id, q.quote, q.source, q.category
  FROM public.daily_quotes q
  WHERE q.mbti_type IS NULL -- general quotes for free tier
  ORDER BY RANDOM()
  LIMIT 1;
END;
$$;
