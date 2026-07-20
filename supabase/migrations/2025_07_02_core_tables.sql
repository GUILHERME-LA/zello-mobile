-- =============================================================
-- ZELLO - MIGRATION (base): tabelas core faltantes
-- (patients, medications, consultations, exams, hospitals,
--  agents, conversations, inbound_messages)
-- Executada ANTES de clinical_features p/ suportar rebuild limpo.
-- Idempotente: CREATE TABLE IF NOT EXISTS / DROP POLICY IF EXISTS /
-- CREATE OR REPLACE FUNCTION.
-- =============================================================

CREATE SCHEMA IF NOT EXISTS zello;

CREATE OR REPLACE FUNCTION zello._touch_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION zello.user_profile_id()
RETURNS uuid
LANGUAGE sql STABLE SECURITY DEFINER
AS $$
  SELECT id FROM zello.profiles WHERE user_id = auth.uid();
$$;

CREATE OR REPLACE FUNCTION zello.user_role()
RETURNS text
LANGUAGE sql STABLE SECURITY DEFINER
AS $$
  SELECT COALESCE(
    (SELECT role FROM zello.profiles WHERE user_id = auth.uid()),
    'patient'
  );
$$;

CREATE OR REPLACE FUNCTION zello.user_professional_id()
RETURNS uuid
LANGUAGE sql STABLE SECURITY DEFINER
AS $$
  SELECT p.id FROM zello.professionals p
  WHERE p.profile_id = zello.user_profile_id();
$$;

CREATE OR REPLACE FUNCTION zello.conversation_belongs_to_user(p_conv_key text)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1 FROM zello.conversations c
    WHERE c.conv_key = p_conv_key AND c.user_id = auth.uid()
  );
$$;

-- 1. patients (professional_id SEM FK: professionals criado em clinical_features)
CREATE TABLE IF NOT EXISTS zello.patients (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
    name text NOT NULL,
    phone text,
    email text,
    cpf text,
    birth_date date,
    city text,
    state text,
    professional_id uuid,
    last_access timestamptz,
    total_conversations integer DEFAULT 0,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_patients_user_id ON zello.patients(user_id);
CREATE INDEX IF NOT EXISTS idx_patients_professional_id ON zello.patients(professional_id);

-- 2. medications
CREATE TABLE IF NOT EXISTS zello.medications (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    patient_id uuid REFERENCES zello.patients(id) ON DELETE CASCADE,
    name text NOT NULL,
    dosage text,
    frequency text,
    prescribing_doctor text,
    prescribed_by uuid REFERENCES zello.professionals(id) ON DELETE SET NULL,
    start_date date,
    end_date date,
    is_active boolean DEFAULT true,
    next_dose timestamptz,
    observations text,
    discontinued_at timestamptz,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_medications_patient ON zello.medications(patient_id);

-- 3. consultations
CREATE TABLE IF NOT EXISTS zello.consultations (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    patient_id uuid REFERENCES zello.patients(id) ON DELETE CASCADE,
    doctor_name text,
    specialty text,
    date timestamptz,
    type text DEFAULT 'in_person',
    notes text,
    prescriptions jsonb DEFAULT '[]'::jsonb,
    status text DEFAULT 'scheduled',
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_consultations_patient ON zello.consultations(patient_id);

-- 4. exams
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
CREATE INDEX IF NOT EXISTS idx_exams_patient ON zello.exams(patient_id);
CREATE INDEX IF NOT EXISTS idx_exams_status ON zello.exams(status);
DO $$ BEGIN
  ALTER TABLE zello.exams ADD COLUMN IF NOT EXISTS requested_by uuid REFERENCES zello.professionals(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_column THEN NULL;
END $$;
ALTER TABLE zello.exams ADD COLUMN IF NOT EXISTS requested_at timestamptz DEFAULT now();
ALTER TABLE zello.exams ADD COLUMN IF NOT EXISTS notes text;

-- 5. hospitals
CREATE TABLE IF NOT EXISTS zello.hospitals (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    name text NOT NULL,
    address text,
    phone text,
    latitude double precision,
    longitude double precision,
    distance double precision,
    plan text,
    specialties jsonb DEFAULT '[]'::jsonb,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 6. agents
CREATE TABLE IF NOT EXISTS zello.agents (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    name text NOT NULL,
    type text NOT NULL DEFAULT 'medico' CHECK (type IN ('medico', 'psicologo')),
    status text NOT NULL DEFAULT 'offline' CHECK (status IN ('online', 'busy', 'offline')),
    active_conversations integer DEFAULT 0,
    total_handled integer DEFAULT 0,
    avg_response_time numeric DEFAULT 0,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 7. conversations
CREATE TABLE IF NOT EXISTS zello.conversations (
    conv_key text PRIMARY KEY,
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    phone text,
    status text NOT NULL DEFAULT 'ongoing' CHECK (status IN ('ongoing', 'closed')),
    last_message_at timestamptz,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_conversations_user_id ON zello.conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_conversations_status ON zello.conversations(status);
DO $$ BEGIN
  ALTER TABLE zello.conversations ADD COLUMN IF NOT EXISTS professional_id uuid;
EXCEPTION WHEN duplicate_column THEN NULL;
END $$;

-- 8. inbound_messages
CREATE TABLE IF NOT EXISTS zello.inbound_messages (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    conv_key text REFERENCES zello.conversations(conv_key) ON DELETE CASCADE,
    sender text NOT NULL DEFAULT 'user' CHECK (sender IN ('user', 'agent')),
    text text,
    type text DEFAULT 'text',
    received_at timestamptz DEFAULT now(),
    raw jsonb DEFAULT '{}'::jsonb
);
CREATE INDEX IF NOT EXISTS idx_inbound_conv ON zello.inbound_messages(conv_key, received_at);

-- TRIGGERS updated_at
DROP TRIGGER IF EXISTS trg_patients_updated_at ON zello.patients;
CREATE TRIGGER trg_patients_updated_at BEFORE UPDATE ON zello.patients
    FOR EACH ROW EXECUTE FUNCTION zello._touch_updated_at();
DROP TRIGGER IF EXISTS trg_medications_updated_at ON zello.medications;
CREATE TRIGGER trg_medications_updated_at BEFORE UPDATE ON zello.medications
    FOR EACH ROW EXECUTE FUNCTION zello._touch_updated_at();
DROP TRIGGER IF EXISTS trg_consultations_updated_at ON zello.consultations;
CREATE TRIGGER trg_consultations_updated_at BEFORE UPDATE ON zello.consultations
    FOR EACH ROW EXECUTE FUNCTION zello._touch_updated_at();
DROP TRIGGER IF EXISTS trg_exams_updated_at ON zello.exams;
CREATE TRIGGER trg_exams_updated_at BEFORE UPDATE ON zello.exams
    FOR EACH ROW EXECUTE FUNCTION zello._touch_updated_at();
DROP TRIGGER IF EXISTS trg_hospitals_updated_at ON zello.hospitals;
CREATE TRIGGER trg_hospitals_updated_at BEFORE UPDATE ON zello.hospitals
    FOR EACH ROW EXECUTE FUNCTION zello._touch_updated_at();
DROP TRIGGER IF EXISTS trg_agents_updated_at ON zello.agents;
CREATE TRIGGER trg_agents_updated_at BEFORE UPDATE ON zello.agents
    FOR EACH ROW EXECUTE FUNCTION zello._touch_updated_at();
DROP TRIGGER IF EXISTS trg_conversations_updated_at ON zello.conversations;
CREATE TRIGGER trg_conversations_updated_at BEFORE UPDATE ON zello.conversations
    FOR EACH ROW EXECUTE FUNCTION zello._touch_updated_at();

-- RLS
ALTER TABLE zello.patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE zello.medications ENABLE ROW LEVEL SECURITY;
ALTER TABLE zello.consultations ENABLE ROW LEVEL SECURITY;
ALTER TABLE zello.exams ENABLE ROW LEVEL SECURITY;
ALTER TABLE zello.hospitals ENABLE ROW LEVEL SECURITY;
ALTER TABLE zello.agents ENABLE ROW LEVEL SECURITY;
ALTER TABLE zello.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE zello.inbound_messages ENABLE ROW LEVEL SECURITY;

-- PATIENTS
DROP POLICY IF EXISTS patients_service_rw ON zello.patients;
CREATE POLICY patients_service_rw ON zello.patients FOR ALL TO service_role USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS patients_select_own ON zello.patients;
CREATE POLICY patients_select_own ON zello.patients FOR SELECT TO authenticated USING (user_id = auth.uid() OR zello.user_role() = 'admin');
DROP POLICY IF EXISTS patients_select_professional ON zello.patients;
CREATE POLICY patients_select_professional ON zello.patients FOR SELECT TO authenticated USING (professional_id = zello.user_professional_id() OR zello.user_role() = 'admin');
DROP POLICY IF EXISTS patients_insert_admin ON zello.patients;
CREATE POLICY patients_insert_admin ON zello.patients FOR INSERT TO authenticated WITH CHECK (zello.user_role() = 'admin');
DROP POLICY IF EXISTS patients_update_admin ON zello.patients;
CREATE POLICY patients_update_admin ON zello.patients FOR UPDATE TO authenticated USING (user_id = auth.uid() OR professional_id = zello.user_professional_id() OR zello.user_role() = 'admin') WITH CHECK (user_id = auth.uid() OR professional_id = zello.user_professional_id() OR zello.user_role() = 'admin');

-- MEDICATIONS
DROP POLICY IF EXISTS medications_service_rw ON zello.medications;
CREATE POLICY medications_service_rw ON zello.medications FOR ALL TO service_role USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS medications_admin_all ON zello.medications;
CREATE POLICY medications_admin_all ON zello.medications FOR ALL TO authenticated USING (zello.user_role() = 'admin') WITH CHECK (zello.user_role() = 'admin');
DROP POLICY IF EXISTS medications_professional_all ON zello.medications;
CREATE POLICY medications_professional_all ON zello.medications FOR ALL TO authenticated USING (patient_id IN (SELECT id FROM zello.patients WHERE professional_id = zello.user_professional_id())) WITH CHECK (patient_id IN (SELECT id FROM zello.patients WHERE professional_id = zello.user_professional_id()));
DROP POLICY IF EXISTS medications_patient_select ON zello.medications;
CREATE POLICY medications_patient_select ON zello.medications FOR SELECT TO authenticated USING (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));

-- CONSULTATIONS
DROP POLICY IF EXISTS consultations_service_rw ON zello.consultations;
CREATE POLICY consultations_service_rw ON zello.consultations FOR ALL TO service_role USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS consultations_admin_all ON zello.consultations;
CREATE POLICY consultations_admin_all ON zello.consultations FOR ALL TO authenticated USING (zello.user_role() = 'admin') WITH CHECK (zello.user_role() = 'admin');
DROP POLICY IF EXISTS consultations_professional_all ON zello.consultations;
CREATE POLICY consultations_professional_all ON zello.consultations FOR ALL TO authenticated USING (patient_id IN (SELECT id FROM zello.patients WHERE professional_id = zello.user_professional_id())) WITH CHECK (patient_id IN (SELECT id FROM zello.patients WHERE professional_id = zello.user_professional_id()));
DROP POLICY IF EXISTS consultations_patient_select ON zello.consultations;
CREATE POLICY consultations_patient_select ON zello.consultations FOR SELECT TO authenticated USING (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));

-- EXAMS
DROP POLICY IF EXISTS exams_service_rw ON zello.exams;
CREATE POLICY exams_service_rw ON zello.exams FOR ALL TO service_role USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS exams_admin_all ON zello.exams;
CREATE POLICY exams_admin_all ON zello.exams FOR ALL TO authenticated USING (zello.user_role() = 'admin') WITH CHECK (zello.user_role() = 'admin');
DROP POLICY IF EXISTS exams_professional_all ON zello.exams;
CREATE POLICY exams_professional_all ON zello.exams FOR ALL TO authenticated USING (patient_id IN (SELECT id FROM zello.patients WHERE professional_id = zello.user_professional_id()) OR requested_by = zello.user_professional_id()) WITH CHECK (patient_id IN (SELECT id FROM zello.patients WHERE professional_id = zello.user_professional_id()) OR requested_by = zello.user_professional_id());
DROP POLICY IF EXISTS exams_patient_select ON zello.exams;
CREATE POLICY exams_patient_select ON zello.exams FOR SELECT TO authenticated USING (patient_id IN (SELECT id FROM zello.patients WHERE user_id = auth.uid()));

-- HOSPITALS
DROP POLICY IF EXISTS hospitals_service_rw ON zello.hospitals;
CREATE POLICY hospitals_service_rw ON zello.hospitals FOR ALL TO service_role USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS hospitals_select_all ON zello.hospitals;
CREATE POLICY hospitals_select_all ON zello.hospitals FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS hospitals_admin_write ON zello.hospitals;
CREATE POLICY hospitals_admin_write ON zello.hospitals FOR INSERT TO authenticated WITH CHECK (zello.user_role() = 'admin');

-- AGENTS
DROP POLICY IF EXISTS agents_service_rw ON zello.agents;
CREATE POLICY agents_service_rw ON zello.agents FOR ALL TO service_role USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS agents_select_all ON zello.agents;
CREATE POLICY agents_select_all ON zello.agents FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS agents_admin_write ON zello.agents;
CREATE POLICY agents_admin_write ON zello.agents FOR ALL TO authenticated USING (zello.user_role() = 'admin') WITH CHECK (zello.user_role() = 'admin');

-- CONVERSATIONS
DROP POLICY IF EXISTS conversations_service_rw ON zello.conversations;
CREATE POLICY conversations_service_rw ON zello.conversations FOR ALL TO service_role USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS conversations_select_own ON zello.conversations;
CREATE POLICY conversations_select_own ON zello.conversations FOR SELECT TO authenticated USING (user_id = auth.uid() OR zello.user_role() = 'admin' OR professional_id IN (SELECT id FROM zello.patients WHERE professional_id = zello.user_professional_id()));
DROP POLICY IF EXISTS conversations_insert_admin ON zello.conversations;
CREATE POLICY conversations_insert_admin ON zello.conversations FOR INSERT TO authenticated WITH CHECK (zello.user_role() = 'admin' OR user_id = auth.uid());
DROP POLICY IF EXISTS conversations_update_admin ON zello.conversations;
CREATE POLICY conversations_update_admin ON zello.conversations FOR UPDATE TO authenticated USING (zello.user_role() = 'admin' OR user_id = auth.uid()) WITH CHECK (zello.user_role() = 'admin' OR user_id = auth.uid());

-- INBOUND_MESSAGES
DROP POLICY IF EXISTS inbound_service_rw ON zello.inbound_messages;
CREATE POLICY inbound_service_rw ON zello.inbound_messages FOR ALL TO service_role USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS inbound_select_own ON zello.inbound_messages;
CREATE POLICY inbound_select_own ON zello.inbound_messages FOR SELECT TO authenticated USING (zello.conversation_belongs_to_user(conv_key) OR zello.user_role() = 'admin');
DROP POLICY IF EXISTS inbound_insert_own ON zello.inbound_messages;
CREATE POLICY inbound_insert_own ON zello.inbound_messages FOR INSERT TO authenticated WITH CHECK (zello.conversation_belongs_to_user(conv_key) OR zello.user_role() = 'admin');

-- GRANTS
GRANT USAGE ON SCHEMA zello TO anon, authenticated;
GRANT ALL ON zello.patients TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON zello.patients TO authenticated;
GRANT ALL ON zello.medications TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON zello.medications TO authenticated;
GRANT ALL ON zello.consultations TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON zello.consultations TO authenticated;
GRANT ALL ON zello.exams TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON zello.exams TO authenticated;
GRANT ALL ON zello.hospitals TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON zello.hospitals TO authenticated;
GRANT ALL ON zello.agents TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON zello.agents TO authenticated;
GRANT ALL ON zello.conversations TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON zello.conversations TO authenticated;
GRANT ALL ON zello.inbound_messages TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON zello.inbound_messages TO authenticated;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA zello TO authenticated;
