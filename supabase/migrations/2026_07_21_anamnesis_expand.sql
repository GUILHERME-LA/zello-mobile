-- =============================================================
-- ZELLO - MIGRATION: Expansão da anamnese para onboarding do paciente
-- Schema: zello
-- Supabase (PostgreSQL 15+)
-- =============================================================

-- =============================================================
-- 1. NOVAS COLUNAS NA TABELA anamneses
-- =============================================================
ALTER TABLE zello.anamneses
  ADD COLUMN IF NOT EXISTS rg text,
  ADD COLUMN IF NOT EXISTS altura numeric(5,2),
  ADD COLUMN IF NOT EXISTS has_depression boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS has_suicide_attempts boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS has_self_harm boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS mental_health_notes text,
  ADD COLUMN IF NOT EXISTS allergies_details text,
  ADD COLUMN IF NOT EXISTS surgeries_description text,
  ADD COLUMN IF NOT EXISTS has_insurance boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS insurance_provider text,
  ADD COLUMN IF NOT EXISTS insurance_plan text,
  ADD COLUMN IF NOT EXISTS address_street text,
  ADD COLUMN IF NOT EXISTS address_number text,
  ADD COLUMN IF NOT EXISTS address_neighborhood text,
  ADD COLUMN IF NOT EXISTS address_city text,
  ADD COLUMN IF NOT EXISTS address_state text,
  ADD COLUMN IF NOT EXISTS address_zip text;

-- =============================================================
-- 2. RLS - Permitir que o paciente INSIRA própria anamnese
-- =============================================================
DROP POLICY IF EXISTS anamneses_patient_insert ON zello.anamneses;
CREATE POLICY anamneses_patient_insert ON zello.anamneses
    FOR INSERT TO authenticated
    WITH CHECK (
        patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid())
    );

-- =============================================================
-- 3. RLS - Permitir que o paciente ATUALIZE própria anamnese
-- =============================================================
DROP POLICY IF EXISTS anamneses_patient_update ON zello.anamneses;
CREATE POLICY anamneses_patient_update ON zello.anamneses
    FOR UPDATE TO authenticated
    USING (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()))
    WITH CHECK (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));

-- =============================================================
-- 4. INDEX
-- =============================================================
CREATE INDEX IF NOT EXISTS idx_anamneses_completed ON zello.anamneses(patient_id, completed);
