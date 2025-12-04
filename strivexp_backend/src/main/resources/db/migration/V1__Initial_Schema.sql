-- Habilitar extensão (precisa de superuser)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- enums como domain ou type via check ou enum type
CREATE TYPE challenge_status AS ENUM ('assigned','completed','skipped','failed');
CREATE TYPE xp_event_type AS ENUM ('challenge_completion','daily_bonus','purchase','manual_adjustment');
CREATE TYPE platform_type AS ENUM ('android','ios');
CREATE TYPE challenge_recurrence AS ENUM ('daily','one_off','repeatable');

-- USERS
CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  password_hash text NOT NULL,
  display_name text,
  last_name text NOT NULL,
  username text UNIQUE,
  birthday_date date NOT NULL,
  avatar text,
  timezone text DEFAULT 'UTC',
  locale text DEFAULT 'us_EN',
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- CATEGORIES
CREATE TABLE categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text UNIQUE NOT NULL,
  name text NOT NULL,
  description text,
  icon text,
  created_at timestamptz DEFAULT now()
);

-- CHALLENGES
CREATE TABLE challenges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  category_id uuid NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
  difficulty smallint CHECK (difficulty BETWEEN 1 AND 5),
  xp_reward integer NOT NULL DEFAULT 10,
  motivation_text text,
  is_active boolean DEFAULT true,
  recurrence challenge_recurrence DEFAULT 'daily',
  metadata jsonb, -- regras flexíveis (por ex. {"time_minutes":10})
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- USER_CATEGORIES (N:N)
CREATE TABLE user_categories (
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  category_id uuid NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  priority smallint DEFAULT 0,
  subscribed boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (user_id, category_id)
);

-- USER_CHALLENGES (instâncias/histórico)
CREATE TABLE user_challenges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  challenge_id uuid NOT NULL REFERENCES challenges(id) ON DELETE RESTRICT,
  assigned_date date NOT NULL,
  due_date date,
  status challenge_status NOT NULL DEFAULT 'assigned',
  completed_at timestamptz,
  xp_awarded integer DEFAULT 0,
  attempt_count smallint DEFAULT 0,
  note text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE (user_id, challenge_id, assigned_date) -- evita duplicados no mesmo dia
);

CREATE INDEX idx_user_challenges_user_assigned ON user_challenges (user_id, assigned_date);
CREATE INDEX idx_user_challenges_status ON user_challenges (user_id, status);

-- XP_EVENTS
CREATE TABLE xp_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  amount integer NOT NULL,
  type xp_event_type NOT NULL,
  reference_id uuid, -- aponta para user_challenges.id ou similar
  note text,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX idx_xp_events_user_created ON xp_events (user_id, created_at);

-- BADGES
CREATE TABLE badges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text UNIQUE NOT NULL,
  name text NOT NULL,
  description text,
  icon text,
  xp_reward integer DEFAULT 0,
  metadata jsonb,
  created_at timestamptz DEFAULT now()
);

-- USER_BADGES
CREATE TABLE user_badges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  badge_id uuid NOT NULL REFERENCES badges(id) ON DELETE RESTRICT,
  awarded_at timestamptz DEFAULT now(),
  source_reference uuid,
  revoked boolean DEFAULT false,
  note text,
  UNIQUE (user_id, badge_id) -- cada badge única por usuário
);

CREATE INDEX idx_user_badges_user ON user_badges (user_id);

-- PUSH TOKENS
CREATE TABLE push_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  token text NOT NULL UNIQUE,
  platform platform_type,
  last_seen_at timestamptz,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- NOTIFICATIONS
CREATE TABLE notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  push_token_id uuid REFERENCES push_tokens(id) ON DELETE SET NULL,
  title text,
  body text,
  payload jsonb,
  sent_at timestamptz,
  status text, -- ex: sent, delivered, failed
  response jsonb,
  created_at timestamptz DEFAULT now()
);

-- USER_STREAKS (materializado)
CREATE TABLE user_streaks (
  user_id uuid PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  current_streak integer DEFAULT 0,
  longest_streak integer DEFAULT 0,
  last_completed_date date,
  updated_at timestamptz DEFAULT now()
);

-- SETTINGS
CREATE TABLE user_settings (
  user_id uuid PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  daily_notification_time time,
  locale text,
  receive_marketing boolean DEFAULT false,
  daily_challenge_limit smallint DEFAULT 3 CHECK (daily_challenge_limit BETWEEN 1 AND 10),
  vibration_enabled boolean DEFAULT true,
  motivational_messages_enabled boolean DEFAULT true,
  sound_effects_enabled boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);


