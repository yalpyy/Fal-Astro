-- ============================================================================
-- Notification logs table for tracking sent notifications
-- IDEMPOTENT: Safe to run multiple times
-- ============================================================================

CREATE TABLE IF NOT EXISTS notification_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sent_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  topic TEXT,
  token_count INT DEFAULT 0,
  success_count INT DEFAULT 0,
  failure_count INT DEFAULT 0,
  data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for querying
CREATE INDEX IF NOT EXISTS idx_notification_logs_created_at ON notification_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notification_logs_sent_by ON notification_logs(sent_by);

-- Enable RLS
ALTER TABLE notification_logs ENABLE ROW LEVEL SECURITY;

-- Only admins can view notification logs
DROP POLICY IF EXISTS "Admins can view notification logs" ON notification_logs;
CREATE POLICY "Admins can view notification logs"
  ON notification_logs FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.is_admin = true
    )
  );

-- System can insert logs (via Edge Functions)
DROP POLICY IF EXISTS "System can insert notification logs" ON notification_logs;
CREATE POLICY "System can insert notification logs"
  ON notification_logs FOR INSERT
  WITH CHECK (true);

-- Add is_admin field to profiles if not exists
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT false;

-- Add FCM token field to profiles for device-specific notifications
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS fcm_token TEXT;

-- Add notification preferences
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS notification_preferences JSONB DEFAULT '{"daily_horoscope": true, "promotions": true, "reminders": true}'::jsonb;

-- Function to update FCM token
CREATE OR REPLACE FUNCTION update_fcm_token(token TEXT)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE profiles
  SET fcm_token = token, updated_at = NOW()
  WHERE id = auth.uid();
END;
$$;

GRANT EXECUTE ON FUNCTION update_fcm_token(TEXT) TO authenticated;

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================
