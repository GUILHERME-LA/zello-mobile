-- Add schedule_time column to medications table for medication reminder scheduling
-- This stores the time of day in "HH:mm" format (e.g., "08:00", "14:30")

ALTER TABLE zello.medications ADD COLUMN IF NOT EXISTS schedule_time TEXT DEFAULT NULL;

-- Index for quick lookup of medications with scheduled reminders
CREATE INDEX IF NOT EXISTS idx_medications_schedule_time ON zello.medications(schedule_time) WHERE schedule_time IS NOT NULL;
