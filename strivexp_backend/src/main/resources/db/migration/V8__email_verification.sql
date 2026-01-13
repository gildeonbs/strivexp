-- 1. Add verified flag to users
ALTER TABLE users ADD COLUMN email_verified boolean DEFAULT false;

-- 2. Create Verification Tokens table
CREATE TABLE email_verification_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash text NOT NULL,
  expiry_date timestamptz NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX idx_email_verification_user ON email_verification_tokens (user_id);

