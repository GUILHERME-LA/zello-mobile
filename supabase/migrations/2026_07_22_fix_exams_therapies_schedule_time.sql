-- Combined fix: ensure exams, therapies tables and schedule_time column exist
-- Run this in Supabase SQL Editor if tables/columns are missing

-- Ensure exams table exists with title column
CREATE TABLE IF NOT EXISTS zello.exams (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    patient_id uuid REFERENCES zello.patients(id) ON DELETE CASCADE,
    title text NOT NULL,
    exam_type text,
    status text NOT NULL DEFAULT 'solicitado'
        CHECK (status IN ('solicitado', 'confirmado', 'recusado', 'concluido', 'cancelado')),
    result_url text,
    requested_by uuid REFERENCES zello.professionals(id) ON DELETE SET NULL,
    requested_at timestamptz DEFAULT now(),
    notes text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Add title column if exams table exists but title doesn't
ALTER TABLE zello.exams ADD COLUMN IF NOT EXISTS title text;
ALTER TABLE zello.exams ADD COLUMN IF NOT EXISTS exam_type text;
ALTER TABLE zello.exams ADD COLUMN IF NOT EXISTS status text NOT NULL DEFAULT 'solicitado';
ALTER TABLE zello.exams ADD COLUMN IF NOT EXISTS result_url text;
ALTER TABLE zello.exams ADD COLUMN IF NOT EXISTS requested_at timestamptz DEFAULT now();
ALTER TABLE zello.exams ADD COLUMN IF NOT EXISTS notes text;

CREATE INDEX IF NOT EXISTS idx_exams_patient ON zello.exams(patient_id);
CREATE INDEX IF NOT EXISTS idx_exams_status ON zello.exams(status);

-- Ensure therapies table exists
CREATE TABLE IF NOT EXISTS zello.therapies (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    patient_id uuid REFERENCES zello.patients(id) ON DELETE CASCADE,
    name text NOT NULL,
    professional text,
    type text NOT NULL DEFAULT 'outro'
        CHECK (type IN ('fisica', 'ocupacional', 'fonoaudiologica', 'psicologica', 'outro')),
    frequency text,
    start_date date,
    end_date date,
    status text NOT NULL DEFAULT 'ativa'
        CHECK (status IN ('ativa', 'concluida', 'pausada')),
    notes text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_therapies_patient ON zello.therapies(patient_id);

-- Add schedule_time to medications
ALTER TABLE zello.medications ADD COLUMN IF NOT EXISTS schedule_time TEXT DEFAULT NULL;
CREATE INDEX IF NOT EXISTS idx_medications_schedule_time ON zello.medications(schedule_time) WHERE schedule_time IS NOT NULL;

-- Enable RLS on exams and therapies if not already
ALTER TABLE zello.exams ENABLE ROW LEVEL SECURITY;
ALTER TABLE zello.therapies ENABLE ROW LEVEL SECURITY;

-- Exams RLS policies
DROP POLICY IF EXISTS exams_service_rw ON zello.exams;
CREATE POLICY exams_service_rw ON zello.exams FOR ALL TO service_role USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS exams_patient_select ON zello.exams;
CREATE POLICY exams_patient_select ON zello.exams FOR SELECT TO authenticated USING (
    patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid())
);

-- Therapies RLS policies
DROP POLICY IF EXISTS therapies_service_rw ON zello.therapies;
CREATE POLICY therapies_service_rw ON zello.therapies FOR ALL TO service_role USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS therapies_patient_select ON zello.therapies;
CREATE POLICY therapies_patient_select ON zello.therapies FOR SELECT TO authenticated USING (
    patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid())
);
