-- =============================================================
-- ZELLO - MIGRATION: Terapias, Tratamentos e Anamnese
-- Schema: zello
-- Supabase (PostgreSQL 15+)
-- =============================================================

-- =============================================================
-- 1. TABELA therapies
-- =============================================================
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

-- =============================================================
-- 2. TABELA treatments
-- =============================================================
CREATE TABLE IF NOT EXISTS zello.treatments (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    patient_id uuid REFERENCES zello.patients(id) ON DELETE CASCADE,
    name text NOT NULL,
    description text,
    professional text,
    start_date date,
    end_date date,
    status text NOT NULL DEFAULT 'ativo'
        CHECK (status IN ('ativo', 'concluido', 'suspenso')),
    notes text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_treatments_patient ON zello.treatments(patient_id);

-- =============================================================
-- 3. TABELA anamneses
-- =============================================================
CREATE TABLE IF NOT EXISTS zello.anamneses (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    patient_id uuid REFERENCES zello.patients(id) ON DELETE CASCADE,
    date date,
    professional text,
    chief_complaint text,
    history_present_illness text,
    past_history text,
    continuous_medication text,
    allergies text,
    habits text,
    family_history text,
    completed boolean DEFAULT false,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_anamneses_patient ON zello.anamneses(patient_id);

-- =============================================================
-- TRIGGERS (_touch_updated_at)
-- =============================================================
DROP TRIGGER IF EXISTS trg_therapies_updated_at ON zello.therapies;
CREATE TRIGGER trg_therapies_updated_at
    BEFORE UPDATE ON zello.therapies
    FOR EACH ROW EXECUTE FUNCTION zello._touch_updated_at();

DROP TRIGGER IF EXISTS trg_treatments_updated_at ON zello.treatments;
CREATE TRIGGER trg_treatments_updated_at
    BEFORE UPDATE ON zello.treatments
    FOR EACH ROW EXECUTE FUNCTION zello._touch_updated_at();

DROP TRIGGER IF EXISTS trg_anamneses_updated_at ON zello.anamneses;
CREATE TRIGGER trg_anamneses_updated_at
    BEFORE UPDATE ON zello.anamneses
    FOR EACH ROW EXECUTE FUNCTION zello._touch_updated_at();

-- =============================================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================================
ALTER TABLE zello.therapies ENABLE ROW LEVEL SECURITY;
ALTER TABLE zello.treatments ENABLE ROW LEVEL SECURITY;
ALTER TABLE zello.anamneses ENABLE ROW LEVEL SECURITY;

-- --- THERAPIES ---
DROP POLICY IF EXISTS therapies_admin_all ON zello.therapies;
CREATE POLICY therapies_admin_all ON zello.therapies
    FOR ALL TO authenticated
    USING (zello.user_role() = 'admin')
    WITH CHECK (zello.user_role() = 'admin');
DROP POLICY IF EXISTS therapies_professional_all ON zello.therapies;
CREATE POLICY therapies_professional_all ON zello.therapies
    FOR ALL TO authenticated
    USING (patient_id IN (SELECT id FROM zello.patients WHERE professional_id = zello.user_professional_id()))
    WITH CHECK (patient_id IN (SELECT id FROM zello.patients WHERE professional_id = zello.user_professional_id()));
DROP POLICY IF EXISTS therapies_patient_select ON zello.therapies;
CREATE POLICY therapies_patient_select ON zello.therapies
    FOR SELECT TO authenticated
    USING (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));

-- --- TREATMENTS ---
DROP POLICY IF EXISTS treatments_admin_all ON zello.treatments;
CREATE POLICY treatments_admin_all ON zello.treatments
    FOR ALL TO authenticated
    USING (zello.user_role() = 'admin')
    WITH CHECK (zello.user_role() = 'admin');
DROP POLICY IF EXISTS treatments_professional_all ON zello.treatments;
CREATE POLICY treatments_professional_all ON zello.treatments
    FOR ALL TO authenticated
    USING (patient_id IN (SELECT id FROM zello.patients WHERE professional_id = zello.user_professional_id()))
    WITH CHECK (patient_id IN (SELECT id FROM zello.patients WHERE professional_id = zello.user_professional_id()));
DROP POLICY IF EXISTS treatments_patient_select ON zello.treatments;
CREATE POLICY treatments_patient_select ON zello.treatments
    FOR SELECT TO authenticated
    USING (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));

-- --- ANAMNESES ---
DROP POLICY IF EXISTS anamneses_admin_all ON zello.anamneses;
CREATE POLICY anamneses_admin_all ON zello.anamneses
    FOR ALL TO authenticated
    USING (zello.user_role() = 'admin')
    WITH CHECK (zello.user_role() = 'admin');
DROP POLICY IF EXISTS anamneses_professional_all ON zello.anamneses;
CREATE POLICY anamneses_professional_all ON zello.anamneses
    FOR ALL TO authenticated
    USING (patient_id IN (SELECT id FROM zello.patients WHERE professional_id = zello.user_professional_id()))
    WITH CHECK (patient_id IN (SELECT id FROM zello.patients WHERE professional_id = zello.user_professional_id()));
DROP POLICY IF EXISTS anamneses_patient_select ON zello.anamneses;
CREATE POLICY anamneses_patient_select ON zello.anamneses
    FOR SELECT TO authenticated
    USING (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));

-- =============================================================
-- GRANTS
-- =============================================================
GRANT ALL ON zello.therapies TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON zello.therapies TO authenticated;
GRANT ALL ON zello.treatments TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON zello.treatments TO authenticated;
GRANT ALL ON zello.anamneses TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON zello.anamneses TO authenticated;
