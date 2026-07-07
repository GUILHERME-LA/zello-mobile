-- =============================================================
-- ZELLO - MIGRATION: Clinical Features (RBAC, Profissionais,
--         Agenda, Solicitacao de Exames, Convênio, LGPD)
-- Schema: zello
-- Supabase (PostgreSQL 15+)
-- =============================================================

-- =============================================================
-- 1. TABELA profiles (unifica perfis com role)
-- =============================================================
CREATE TABLE zello.profiles (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
    role text NOT NULL CHECK (role IN ('admin', 'professional', 'patient')),
    name text NOT NULL,
    phone text,
    avatar_url text,
    consent_lgpd_at timestamptz,
    consent_lgpd_version text,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_profiles_user_id ON zello.profiles(user_id);
CREATE INDEX idx_profiles_role ON zello.profiles(role);

-- =============================================================
-- 2. TABELA professionals
-- =============================================================
CREATE TABLE zello.professionals (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    profile_id uuid REFERENCES zello.profiles(id) ON DELETE CASCADE UNIQUE,
    type text NOT NULL CHECK (type IN ('medico', 'psicologo')),
    specialty text,
    council text NOT NULL,
    council_uf text NOT NULL,
    bio text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_professionals_profile_id ON zello.professionals(profile_id);

-- =============================================================
-- 3. AJUSTE em patients: adicionar professional_id, city, state
-- =============================================================
ALTER TABLE zello.patients
    ADD COLUMN IF NOT EXISTS professional_id uuid REFERENCES zello.professionals(id),
    ADD COLUMN IF NOT EXISTS city text,
    ADD COLUMN IF NOT EXISTS state text;

CREATE INDEX IF NOT EXISTS idx_patients_professional_id ON zello.patients(professional_id);

-- =============================================================
-- 4. AJUSTE em medications: substituir prescribing_doctor, adicionar campos
-- =============================================================
ALTER TABLE zello.medications
    ADD COLUMN IF NOT EXISTS prescribed_by uuid REFERENCES zello.professionals(id),
    ADD COLUMN IF NOT EXISTS observations text,
    ADD COLUMN IF NOT EXISTS discontinued_at timestamptz;

-- =============================================================
-- 5. TABELA professional_availability (slots de agenda)
-- =============================================================
CREATE TABLE zello.professional_availability (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    professional_id uuid REFERENCES zello.professionals(id) ON DELETE CASCADE,
    date date NOT NULL,
    start_time time NOT NULL,
    end_time time NOT NULL,
    is_booked boolean DEFAULT false,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    CHECK (end_time > start_time)
);

CREATE INDEX idx_avail_prof_date ON zello.professional_availability(professional_id, date);

-- =============================================================
-- 6. TABELA exam_requests (solicitação de exames)
-- =============================================================
CREATE TABLE zello.exam_requests (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    patient_id uuid REFERENCES zello.patients(id) ON DELETE CASCADE,
    professional_id uuid REFERENCES zello.professionals(id) ON DELETE CASCADE,
    availability_slot_id uuid REFERENCES zello.professional_availability(id) ON DELETE SET NULL,
    exam_type text NOT NULL,
    notes text,
    status text NOT NULL DEFAULT 'solicitado'
        CHECK (status IN ('solicitado', 'confirmado', 'recusado', 'concluido', 'cancelado')),
    refused_reason text,
    confirmed_at timestamptz,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_exam_req_patient ON zello.exam_requests(patient_id);
CREATE INDEX idx_exam_req_prof ON zello.exam_requests(professional_id);
CREATE INDEX idx_exam_req_status ON zello.exam_requests(status);

-- =============================================================
-- 7. TABELA insurances (convênios do paciente)
-- =============================================================
CREATE TABLE zello.insurances (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    patient_id uuid REFERENCES zello.patients(id) ON DELETE CASCADE,
    provider text NOT NULL,
    plan_name text NOT NULL,
    plan_type text,
    card_number text,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_insurances_patient ON zello.insurances(patient_id);

-- =============================================================
-- 8. TABELA ai_recommendations (log da análise IA)
-- =============================================================
CREATE TABLE zello.ai_recommendations (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    patient_id uuid REFERENCES zello.patients(id) ON DELETE CASCADE,
    insurance_id uuid REFERENCES zello.insurances(id) ON DELETE SET NULL,
    input_text text,
    recommended_hospitals jsonb DEFAULT '[]'::jsonb,
    plan_suggestion jsonb,
    disclaimer_version text DEFAULT '1.0',
    created_at timestamptz DEFAULT now()
);

CREATE INDEX idx_ai_rec_patient ON zello.ai_recommendations(patient_id);

-- =============================================================
-- TRIGGERS (_touch_updated_at)
-- =============================================================
CREATE TRIGGER trg_profiles_updated_at
    BEFORE UPDATE ON zello.profiles
    FOR EACH ROW EXECUTE FUNCTION zello._touch_updated_at();
CREATE TRIGGER trg_professionals_updated_at
    BEFORE UPDATE ON zello.professionals
    FOR EACH ROW EXECUTE FUNCTION zello._touch_updated_at();
CREATE TRIGGER trg_professional_availability_updated_at
    BEFORE UPDATE ON zello.professional_availability
    FOR EACH ROW EXECUTE FUNCTION zello._touch_updated_at();
CREATE TRIGGER trg_exam_requests_updated_at
    BEFORE UPDATE ON zello.exam_requests
    FOR EACH ROW EXECUTE FUNCTION zello._touch_updated_at();
CREATE TRIGGER trg_insurances_updated_at
    BEFORE UPDATE ON zello.insurances
    FOR EACH ROW EXECUTE FUNCTION zello._touch_updated_at();

-- =============================================================
-- FUNÇÃO: zello.user_role() — retorna o role do usuário logado
-- =============================================================
CREATE OR REPLACE FUNCTION zello.user_role()
RETURNS text
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
    SELECT COALESCE(
        (SELECT role FROM zello.profiles WHERE user_id = auth.uid()),
        'patient'
    );
$$;

-- =============================================================
-- FUNÇÃO: zello.user_profile_id() — retorna o profile_id do usuário
-- =============================================================
CREATE OR REPLACE FUNCTION zello.user_profile_id()
RETURNS uuid
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
    SELECT id FROM zello.profiles WHERE user_id = auth.uid();
$$;

-- =============================================================
-- FUNÇÃO: zello.user_professional_id() — retorna professional_id
-- =============================================================
CREATE OR REPLACE FUNCTION zello.user_professional_id()
RETURNS uuid
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
    SELECT p.id FROM zello.professionals p
    WHERE p.profile_id = zello.user_profile_id();
$$;

-- =============================================================
-- ROW LEVEL SECURITY (RLS) — Novas policies
-- =============================================================

-- Habilitar RLS nas novas tabelas
ALTER TABLE zello.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE zello.professionals ENABLE ROW LEVEL SECURITY;
ALTER TABLE zello.professional_availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE zello.exam_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE zello.insurances ENABLE ROW LEVEL SECURITY;
ALTER TABLE zello.ai_recommendations ENABLE ROW LEVEL SECURITY;

-- --- PROFILES ---
-- Admin/Profissional pode ver todos; paciente vê apenas o próprio
CREATE POLICY profiles_admin_rw ON zello.profiles
    FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY profiles_select_own ON zello.profiles
    FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY profiles_select_professional ON zello.profiles
    FOR SELECT TO authenticated
    USING (zello.user_role() = 'professional');
CREATE POLICY profiles_select_admin ON zello.profiles
    FOR SELECT TO authenticated
    USING (zello.user_role() = 'admin');
CREATE POLICY profiles_insert_admin ON zello.profiles
    FOR INSERT TO authenticated
    WITH CHECK (zello.user_role() = 'admin');
CREATE POLICY profiles_update_own ON zello.profiles
    FOR UPDATE TO authenticated
    USING (user_id = auth.uid() OR zello.user_role() = 'admin');

-- --- PROFESSIONALS ---
CREATE POLICY professionals_service_rw ON zello.professionals
    FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY professionals_select_all ON zello.professionals
    FOR SELECT TO authenticated USING (true);
CREATE POLICY professionals_insert_admin ON zello.professionals
    FOR INSERT TO authenticated
    WITH CHECK (zello.user_role() = 'admin');
CREATE POLICY professionals_update_admin ON zello.professionals
    FOR UPDATE TO authenticated
    USING (zello.user_role() = 'admin');

-- --- PROFESSIONAL_AVAILABILITY ---
CREATE POLICY avail_service_rw ON zello.professional_availability
    FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY avail_select_public ON zello.professional_availability
    FOR SELECT TO authenticated USING (true);
CREATE POLICY avail_insert_own ON zello.professional_availability
    FOR INSERT TO authenticated
    WITH CHECK (professional_id = zello.user_professional_id() OR zello.user_role() = 'admin');
CREATE POLICY avail_update_own ON zello.professional_availability
    FOR UPDATE TO authenticated
    USING (professional_id = zello.user_professional_id() OR zello.user_role() = 'admin');

-- --- EXAM_REQUESTS ---
CREATE POLICY exam_req_service_rw ON zello.exam_requests
    FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY exam_req_select_own ON zello.exam_requests
    FOR SELECT TO authenticated
    USING (
        patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid())
        OR professional_id = zello.user_professional_id()
        OR zello.user_role() = 'admin'
    );
CREATE POLICY exam_req_insert_patient ON zello.exam_requests
    FOR INSERT TO authenticated
    WITH CHECK (
        patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid())
        OR zello.user_role() = 'admin'
    );
CREATE POLICY exam_req_update_prof ON zello.exam_requests
    FOR UPDATE TO authenticated
    USING (
        professional_id = zello.user_professional_id()
        OR zello.user_role() = 'admin'
    );

-- --- INSURANCES ---
CREATE POLICY insurances_service_rw ON zello.insurances
    FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY insurances_select_own ON zello.insurances
    FOR SELECT TO authenticated
    USING (
        patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid())
        OR zello.user_role() = 'admin'
    );
CREATE POLICY insurances_insert_own ON zello.insurances
    FOR INSERT TO authenticated
    WITH CHECK (
        patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid())
        OR zello.user_role() = 'admin'
    );

-- --- AI_RECOMMENDATIONS ---
CREATE POLICY ai_rec_service_rw ON zello.ai_recommendations
    FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY ai_rec_select_own ON zello.ai_recommendations
    FOR SELECT TO authenticated
    USING (
        patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid())
        OR zello.user_role() = 'admin'
    );
CREATE POLICY ai_rec_insert_own ON zello.ai_recommendations
    FOR INSERT TO authenticated
    WITH CHECK (
        patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid())
        OR zello.user_role() = 'admin'
    );

-- =============================================================
-- TRIGGER: auto-cria profile ao inserir em auth.users
-- =============================================================
CREATE OR REPLACE FUNCTION zello.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  INSERT INTO zello.profiles (user_id, role, name, email)
  VALUES (
    NEW.id,
    'patient',
    COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
    NEW.email
  )
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION zello.handle_new_user();

-- =============================================================
-- GRANTS
-- =============================================================
GRANT ALL ON zello.profiles TO service_role;
GRANT SELECT ON zello.profiles TO authenticated;
GRANT INSERT, UPDATE ON zello.profiles TO authenticated;
GRANT ALL ON zello.professionals TO service_role;
GRANT SELECT ON zello.professionals TO authenticated;
GRANT INSERT, UPDATE ON zello.professionals TO authenticated;
GRANT ALL ON zello.professional_availability TO service_role;
GRANT SELECT, INSERT, UPDATE ON zello.professional_availability TO authenticated;
GRANT ALL ON zello.exam_requests TO service_role;
GRANT SELECT, INSERT, UPDATE ON zello.exam_requests TO authenticated;
GRANT ALL ON zello.insurances TO service_role;
GRANT SELECT, INSERT, UPDATE ON zello.insurances TO authenticated;
GRANT ALL ON zello.ai_recommendations TO service_role;
GRANT SELECT, INSERT ON zello.ai_recommendations TO authenticated;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA zello TO authenticated;

-- Grants for legacy tables (needed for admin CRUD)
GRANT INSERT, UPDATE, DELETE ON zello.medications TO authenticated;
GRANT INSERT, UPDATE, DELETE ON zello.exams TO authenticated;
GRANT INSERT, UPDATE, DELETE ON zello.consultations TO authenticated;

-- =============================================================
-- RLS: legacy tables (medications, exams, consultations)
-- =============================================================

ALTER TABLE zello.medications ENABLE ROW LEVEL SECURITY;
ALTER TABLE zello.exams ENABLE ROW LEVEL SECURITY;
ALTER TABLE zello.consultations ENABLE ROW LEVEL SECURITY;

-- --- MEDICATIONS ---
-- Admin pode tudo
CREATE POLICY medications_admin_all ON zello.medications
    FOR ALL TO authenticated
    USING (zello.user_role() = 'admin')
    WITH CHECK (zello.user_role() = 'admin');
-- Professional gerencia medicamentos dos seus pacientes
CREATE POLICY medications_professional_all ON zello.medications
    FOR ALL TO authenticated
    USING (patient_id IN (SELECT id FROM zello.patients WHERE professional_id = zello.user_professional_id()))
    WITH CHECK (patient_id IN (SELECT id FROM zello.patients WHERE professional_id = zello.user_professional_id()));
-- Patient vê apenas os próprios medicamentos
CREATE POLICY medications_patient_select ON zello.medications
    FOR SELECT TO authenticated
    USING (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));

-- --- EXAMS ---
CREATE POLICY exams_admin_all ON zello.exams
    FOR ALL TO authenticated
    USING (zello.user_role() = 'admin')
    WITH CHECK (zello.user_role() = 'admin');
CREATE POLICY exams_professional_all ON zello.exams
    FOR ALL TO authenticated
    USING (patient_id IN (SELECT id FROM zello.patients WHERE professional_id = zello.user_professional_id()))
    WITH CHECK (patient_id IN (SELECT id FROM zello.patients WHERE professional_id = zello.user_professional_id()));
CREATE POLICY exams_patient_select ON zello.exams
    FOR SELECT TO authenticated
    USING (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));

-- --- CONSULTATIONS ---
CREATE POLICY consultations_admin_all ON zello.consultations
    FOR ALL TO authenticated
    USING (zello.user_role() = 'admin')
    WITH CHECK (zello.user_role() = 'admin');
CREATE POLICY consultations_professional_all ON zello.consultations
    FOR ALL TO authenticated
    USING (patient_id IN (SELECT id FROM zello.patients WHERE professional_id = zello.user_professional_id()))
    WITH CHECK (patient_id IN (SELECT id FROM zello.patients WHERE professional_id = zello.user_professional_id()));
CREATE POLICY consultations_patient_select ON zello.consultations
    FOR SELECT TO authenticated
    USING (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));
