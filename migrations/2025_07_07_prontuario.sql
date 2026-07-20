-- =============================================================
-- ZELLO - MIGRATION: Prontuario do Paciente
-- Schema: zello
-- Idempotente: CREATE TABLE IF NOT EXISTS / DROP POLICY IF EXISTS
-- =============================================================

-- 1. HEALTH PROFILES
CREATE TABLE IF NOT EXISTS zello.health_profiles (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    patient_id uuid NOT NULL REFERENCES zello.patients(id) ON DELETE CASCADE UNIQUE,
    weight numeric DEFAULT 0,
    height numeric DEFAULT 0,
    blood_type text DEFAULT '',
    medical_conditions text DEFAULT '',
    family_history text DEFAULT '',
    chronic_conditions text DEFAULT '',
    medications text DEFAULT '',
    updated_at timestamptz DEFAULT now()
);

-- 2. SURGERIES
CREATE TABLE IF NOT EXISTS zello.surgeries (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    patient_id uuid NOT NULL REFERENCES zello.patients(id) ON DELETE CASCADE,
    name text NOT NULL,
    date date NOT NULL,
    hospital text DEFAULT '',
    doctor text DEFAULT '',
    notes text DEFAULT '',
    created_at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_surgeries_patient ON zello.surgeries(patient_id);

-- 3. HOSPITALIZATIONS
CREATE TABLE IF NOT EXISTS zello.hospitalizations (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    patient_id uuid NOT NULL REFERENCES zello.patients(id) ON DELETE CASCADE,
    reason text NOT NULL,
    hospital text DEFAULT '',
    start_date date NOT NULL,
    end_date date,
    notes text DEFAULT '',
    created_at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_hospitalizations_patient ON zello.hospitalizations(patient_id);

-- 4. SYMPTOMS
CREATE TABLE IF NOT EXISTS zello.symptoms (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    patient_id uuid NOT NULL REFERENCES zello.patients(id) ON DELETE CASCADE,
    name text NOT NULL,
    frequency text DEFAULT '',
    intensity text DEFAULT '',
    notes text DEFAULT '',
    created_at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_symptoms_patient ON zello.symptoms(patient_id);

-- 5. ALLERGIES
CREATE TABLE IF NOT EXISTS zello.allergies (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    patient_id uuid NOT NULL REFERENCES zello.patients(id) ON DELETE CASCADE,
    name text NOT NULL,
    type text NOT NULL DEFAULT 'medicamento' CHECK (type IN ('medicamento', 'alimento', 'substancia', 'outro')),
    reaction text DEFAULT '',
    notes text DEFAULT '',
    created_at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_allergies_patient ON zello.allergies(patient_id);

-- 6. VACCINES
CREATE TABLE IF NOT EXISTS zello.vaccines (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    patient_id uuid NOT NULL REFERENCES zello.patients(id) ON DELETE CASCADE,
    name text NOT NULL,
    date date NOT NULL,
    dose text DEFAULT '',
    location text DEFAULT '',
    notes text DEFAULT '',
    is_pending boolean DEFAULT false,
    created_at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_vaccines_patient ON zello.vaccines(patient_id);

-- RLS
ALTER TABLE zello.health_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE zello.surgeries ENABLE ROW LEVEL SECURITY;
ALTER TABLE zello.hospitalizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE zello.symptoms ENABLE ROW LEVEL SECURITY;
ALTER TABLE zello.allergies ENABLE ROW LEVEL SECURITY;
ALTER TABLE zello.vaccines ENABLE ROW LEVEL SECURITY;

-- RLS - health_profiles
DROP POLICY IF EXISTS "Paciente pode ver seu perfil" ON zello.health_profiles;
CREATE POLICY "Paciente pode ver seu perfil" ON zello.health_profiles FOR SELECT
    USING (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Paciente pode gerenciar seu perfil" ON zello.health_profiles;
CREATE POLICY "Paciente pode gerenciar seu perfil" ON zello.health_profiles FOR INSERT
    WITH CHECK (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Paciente pode atualizar seu perfil" ON zello.health_profiles;
CREATE POLICY "Paciente pode atualizar seu perfil" ON zello.health_profiles FOR UPDATE
    USING (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));

-- RLS - surgeries
DROP POLICY IF EXISTS "Paciente pode ver cirurgias" ON zello.surgeries;
CREATE POLICY "Paciente pode ver cirurgias" ON zello.surgeries FOR SELECT
    USING (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Paciente pode gerenciar cirurgias" ON zello.surgeries;
CREATE POLICY "Paciente pode gerenciar cirurgias" ON zello.surgeries FOR INSERT
    WITH CHECK (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Paciente pode deletar cirurgias" ON zello.surgeries;
CREATE POLICY "Paciente pode deletar cirurgias" ON zello.surgeries FOR DELETE
    USING (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));

-- RLS - hospitalizations
DROP POLICY IF EXISTS "Paciente pode ver internacoes" ON zello.hospitalizations;
CREATE POLICY "Paciente pode ver internacoes" ON zello.hospitalizations FOR SELECT
    USING (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Paciente pode gerenciar internacoes" ON zello.hospitalizations;
CREATE POLICY "Paciente pode gerenciar internacoes" ON zello.hospitalizations FOR INSERT
    WITH CHECK (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Paciente pode deletar internacoes" ON zello.hospitalizations;
CREATE POLICY "Paciente pode deletar internacoes" ON zello.hospitalizations FOR DELETE
    USING (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));

-- RLS - symptoms
DROP POLICY IF EXISTS "Paciente pode ver sintomas" ON zello.symptoms;
CREATE POLICY "Paciente pode ver sintomas" ON zello.symptoms FOR SELECT
    USING (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Paciente pode gerenciar sintomas" ON zello.symptoms;
CREATE POLICY "Paciente pode gerenciar sintomas" ON zello.symptoms FOR INSERT
    WITH CHECK (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Paciente pode deletar sintomas" ON zello.symptoms;
CREATE POLICY "Paciente pode deletar sintomas" ON zello.symptoms FOR DELETE
    USING (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));

-- RLS - allergies
DROP POLICY IF EXISTS "Paciente pode ver alergias" ON zello.allergies;
CREATE POLICY "Paciente pode ver alergias" ON zello.allergies FOR SELECT
    USING (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Paciente pode gerenciar alergias" ON zello.allergies;
CREATE POLICY "Paciente pode gerenciar alergias" ON zello.allergies FOR INSERT
    WITH CHECK (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Paciente pode deletar alergias" ON zello.allergies;
CREATE POLICY "Paciente pode deletar alergias" ON zello.allergies FOR DELETE
    USING (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));

-- RLS - vaccines
DROP POLICY IF EXISTS "Paciente pode ver vacinas" ON zello.vaccines;
CREATE POLICY "Paciente pode ver vacinas" ON zello.vaccines FOR SELECT
    USING (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Paciente pode gerenciar vacinas" ON zello.vaccines;
CREATE POLICY "Paciente pode gerenciar vacinas" ON zello.vaccines FOR INSERT
    WITH CHECK (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "Paciente pode deletar vacinas" ON zello.vaccines;
CREATE POLICY "Paciente pode deletar vacinas" ON zello.vaccines FOR DELETE
    USING (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));

-- GRANTS
GRANT ALL ON zello.health_profiles TO service_role;
GRANT SELECT, INSERT, UPDATE ON zello.health_profiles TO authenticated;
GRANT ALL ON zello.surgeries TO service_role;
GRANT SELECT, INSERT, DELETE ON zello.surgeries TO authenticated;
GRANT ALL ON zello.hospitalizations TO service_role;
GRANT SELECT, INSERT, DELETE ON zello.hospitalizations TO authenticated;
GRANT ALL ON zello.symptoms TO service_role;
GRANT SELECT, INSERT, DELETE ON zello.symptoms TO authenticated;
GRANT ALL ON zello.allergies TO service_role;
GRANT SELECT, INSERT, DELETE ON zello.allergies TO authenticated;
GRANT ALL ON zello.vaccines TO service_role;
GRANT SELECT, INSERT, DELETE ON zello.vaccines TO authenticated;
