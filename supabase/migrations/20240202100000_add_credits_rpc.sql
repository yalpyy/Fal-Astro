-- Add credits RPC function
-- This function adds credits to a user's account and logs the transaction

CREATE OR REPLACE FUNCTION add_user_credits(
  credit_amount INT,
  transaction_type TEXT DEFAULT 'ad_reward',
  description TEXT DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  current_user_id UUID;
BEGIN
  -- Get current user
  current_user_id := auth.uid();

  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Update user credits
  UPDATE profiles
  SET
    credits = COALESCE(credits, 0) + credit_amount,
    updated_at = NOW()
  WHERE id = current_user_id;

  -- Log the transaction
  INSERT INTO credit_transactions (
    user_id,
    amount,
    transaction_type,
    description,
    created_at
  ) VALUES (
    current_user_id,
    credit_amount,
    transaction_type,
    COALESCE(description,
      CASE transaction_type
        WHEN 'ad_reward' THEN 'Reklam izleme ödülü'
        WHEN 'purchase' THEN 'Kredi satın alımı'
        WHEN 'usage' THEN 'Kredi kullanımı'
        WHEN 'bonus' THEN 'Bonus kredi'
        WHEN 'refund' THEN 'İade'
        ELSE 'Kredi işlemi'
      END
    ),
    NOW()
  );
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION add_user_credits(INT, TEXT, TEXT) TO authenticated;

-- Create credit_transactions table if not exists
CREATE TABLE IF NOT EXISTS credit_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  amount INT NOT NULL,
  transaction_type TEXT NOT NULL CHECK (transaction_type IN ('purchase', 'usage', 'ad_reward', 'bonus', 'refund', 'daily_bonus')),
  description TEXT,
  reference_id TEXT, -- For purchase receipts, etc.
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_credit_transactions_user_id ON credit_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_credit_transactions_created_at ON credit_transactions(created_at DESC);

-- Enable RLS
ALTER TABLE credit_transactions ENABLE ROW LEVEL SECURITY;

-- Users can only view their own transactions
CREATE POLICY "Users can view own credit transactions"
  ON credit_transactions FOR SELECT
  USING (auth.uid() = user_id);

-- Only system can insert (via RPC)
CREATE POLICY "System can insert credit transactions"
  ON credit_transactions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Function to check daily ad reward limit
CREATE OR REPLACE FUNCTION check_daily_ad_limit()
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  today_count INT;
  max_daily_ads INT := 5; -- Maximum 5 ad rewards per day
BEGIN
  SELECT COUNT(*)
  INTO today_count
  FROM credit_transactions
  WHERE user_id = auth.uid()
    AND transaction_type = 'ad_reward'
    AND created_at >= CURRENT_DATE;

  RETURN max_daily_ads - today_count;
END;
$$;

GRANT EXECUTE ON FUNCTION check_daily_ad_limit() TO authenticated;
