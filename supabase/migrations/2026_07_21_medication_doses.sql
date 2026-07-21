-- Migration: Create medication_doses table for tracking when patients take their medications
-- This stores the history of dose-taking with timestamp and dosage info

CREATE TABLE IF NOT EXISTS zello.medication_doses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    medication_id UUID NOT NULL REFERENCES zello.medications(id) ON DELETE CASCADE,
    patient_id UUID NOT NULL REFERENCES zello.patients(id) ON DELETE CASCADE,
    taken_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    dosage TEXT NOT NULL DEFAULT '',
    notes TEXT DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for fast lookups by medication
CREATE INDEX IF NOT EXISTS idx_medication_doses_medication_id ON zello.medication_doses(medication_id);

-- Index for fast lookups by patient
CREATE INDEX IF NOT EXISTS idx_medication_doses_patient_id ON zello.medication_doses(patient_id);

-- Index for ordering by taken_at
CREATE INDEX IF NOT EXISTS idx_medication_doses_taken_at ON zello.medication_doses(taken_at DESC);

-- RLS policies: patients can only see their own dose history
ALTER TABLE zello.medication_doses ENABLE ROW LEVEL SECURITY;

-- Policy: Patients can read their own dose history
CREATE POLICY "Patients read own dose history"
    ON zello.medication_doses
    FOR SELECT
    USING (patient_id = auth.uid());

-- Policy: Patients can insert their own dose records
CREATE POLICY "Patients insert own doses"
    ON zello.medication_doses
    FOR INSERT
    WITH CHECK (patient_id = auth.uid());

-- Policy: Professionals can read doses for patients they have access to
CREATE POLICY "Professionals read patient doses"
    ON zello.medication_doses
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM zello.profiles
            WHERE profiles.id = auth.uid()
            AND profiles.role IN ('admin', 'professional')
        )
    );
