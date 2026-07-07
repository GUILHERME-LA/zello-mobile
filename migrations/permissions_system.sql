-- =============================================================
-- ZELLO - Permissions System (v6 - sem recursion)
-- =============================================================

-- =============================================================
-- 1. Criar tabela permissions
-- =============================================================
CREATE TABLE IF NOT EXISTS zello.permissions (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    professional_id uuid REFERENCES zello.professionals(id) ON DELETE CASCADE,
    permission text NOT NULL,
    granted_by uuid REFERENCES zello.profiles(id),
    created_at timestamptz DEFAULT now(),
    UNIQUE(professional_id, permission)
);

CREATE INDEX IF NOT EXISTS idx_permissions_professional ON zello.permissions(professional_id);
ALTER TABLE zello.permissions ENABLE ROW LEVEL SECURITY;

GRANT SELECT, INSERT, DELETE ON zello.permissions TO authenticated;
GRANT ALL ON zello.permissions TO service_role;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA zello TO authenticated;

-- =============================================================
-- 2. RLS Policies SIMPLIFICADAS (sem usar user_role para evitar recursion)
-- =============================================================

-- PATIENTS - só criar se não existir
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'patients_select_all' AND tablename = 'patients') THEN
        CREATE POLICY patients_select_all ON zello.patients
            FOR SELECT TO authenticated
            USING (user_id = auth.uid() OR auth.role() = 'authenticated');
    END IF;
END $$;

-- EXAMS - política única para SELECT, INSERT, UPDATE
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'exams_all' AND tablename = 'exams') THEN
        CREATE POLICY exams_all ON zello.exams
            FOR ALL TO authenticated
            USING (true)
            WITH CHECK (true);
    END IF;
END $$;

-- CONSULTATIONS
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'consultations_all' AND tablename = 'consultations') THEN
        CREATE POLICY consultations_all ON zello.consultations
            FOR ALL TO authenticated
            USING (true)
            WITH CHECK (true);
    END IF;
END $$;

-- MEDICATIONS
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'medications_all' AND tablename = 'medications') THEN
        CREATE POLICY medications_all ON zello.medications
            FOR ALL TO authenticated
            USING (true)
            WITH CHECK (true);
    END IF;
END $$;

-- PERMISSIONS
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'permissions_admin_all' AND tablename = 'permissions') THEN
        CREATE POLICY permissions_admin_all ON zello.permissions
            FOR ALL TO authenticated
            USING (auth.role() = 'authenticated')
            WITH CHECK (auth.role() = 'authenticated');
    END IF;
END $$;