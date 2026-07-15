-- @typingself Database Schema
-- Run this in Supabase SQL Editor

-- 1. Users table (syncs with Supabase Auth)
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  display_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_active_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Assessment results
CREATE TABLE IF NOT EXISTS assessment_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  test_type TEXT NOT NULL CHECK (test_type IN ('mbti_enneagram', 'big_five', 'attachment', 'disc', 'love_language', 'zi_wei', 'zodiac', 'human_design')),
  mbti_type TEXT,
  enneagram_type TEXT,
  wing TEXT,
  shadow_type TEXT,
  persona_type TEXT,
  mbti_confidence REAL DEFAULT 0,
  ennea_confidence REAL DEFAULT 0,
  mbti_verified BOOLEAN DEFAULT FALSE,
  ennea_verified BOOLEAN DEFAULT FALSE,
  health_score INTEGER DEFAULT 0,
  total_questions INTEGER DEFAULT 0,
  decision_path TEXT,
  raw_scores JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Mood check-ins (daily tracking)
CREATE TABLE IF NOT EXISTS mood_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  mood_score INTEGER CHECK (mood_score >= 1 AND mood_score <= 5),
  mood_label TEXT,
  note TEXT,
  shadow_trigger BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Shadow detection logs (Stage 2)
CREATE TABLE IF NOT EXISTS shadow_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  detected_pattern TEXT,
  trigger_situation TEXT,
  ennea_defense_mechanism TEXT,
  persona_description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Growth progress (Stage 3)
CREATE TABLE IF NOT EXISTS growth_tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  task_type TEXT NOT NULL,
  task_description TEXT NOT NULL,
  completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  difficulty INTEGER CHECK (difficulty >= 1 AND difficulty <= 5),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Stage purchases
CREATE TABLE IF NOT EXISTS purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  stage INTEGER NOT NULL CHECK (stage IN (2, 3, 4)),
  amount REAL NOT NULL,
  stripe_payment_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Naming card saves
CREATE TABLE IF NOT EXISTS naming_cards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  mbti_type TEXT NOT NULL,
  enneagram_type TEXT NOT NULL,
  display_name TEXT NOT NULL,
  emoji TEXT,
  tagline TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_assessment_user ON assessment_results(user_id);
CREATE INDEX idx_mood_user_date ON mood_entries(user_id, created_at);
CREATE INDEX idx_shadow_user ON shadow_logs(user_id);
CREATE INDEX idx_growth_user ON growth_tasks(user_id);
CREATE INDEX idx_purchases_user ON purchases(user_id);

-- Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessment_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE mood_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE shadow_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE growth_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE naming_cards ENABLE ROW LEVEL SECURITY;

-- Users can only read/write their own data
CREATE POLICY user_own_data ON users
  FOR ALL USING (auth.uid() = id);

CREATE POLICY user_own_assessment ON assessment_results
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY user_own_mood ON mood_entries
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY user_own_shadow ON shadow_logs
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY user_own_growth ON growth_tasks
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY user_own_purchases ON purchases
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY user_own_naming ON naming_cards
  FOR ALL USING (auth.uid() = user_id);
