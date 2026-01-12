-- Table for secure password reset tokens
CREATE TABLE password_reset_tokens (
                                       id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
                                       user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                                       token_hash text NOT NULL,
                                       expiry_date timestamptz NOT NULL,
                                       used boolean DEFAULT false,
                                       created_at timestamptz DEFAULT now()
);

CREATE INDEX idx_password_reset_user ON password_reset_tokens (user_id);