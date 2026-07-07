-- =============================================================
-- ZELLO - MIGRATION: Session Notes (Evolução Psicológica) e
--         Referrals (Encaminhamentos)
-- Schema: zello
-- Supabase (PostgreSQL 15+)
-- =============================================================

-- =============================================================
-- 1. TABELA session_notes
--    Registro de sessões/evolução (usado por Psicólogos)
-- =============================================================
CREATE TABLE zello.session_notes (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    patient_id uuid NOT NULL REFERENCES zello.patients(id) ON DELETE CASCADE,
    professional_id uuid NOT NULL REFERENCES zello.professionals(id) ON DELETE CASCADE,
    date date NOT NULL DEFAULT CURRENT_DATE,
    content text NOT NULL,
    mood text DEFAULT 'neutro',
    status text NOT NULL DEFAULT 'realizada' CHECK (status IN ('realizada', 'cancelada', 'remarcada')),
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_session_notes_patient ON zello.session_notes(patient_id);
CREATE INDEX idx_session_notes_professional ON zello.session_notes(professional_id);
CREATE INDEX idx_session_notes_date ON zello.session_notes(date);

-- =============================================================
-- 2. TABELA referrals (Encaminhamentos)
--    Usado por Psicólogos para encaminhar para outras especialidades
-- =============================================================
CREATE TABLE zello.referrals (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    patient_id uuid NOT NULL REFERENCES zello.patients(id) ON DELETE CASCADE,
    from_professional_id uuid NOT NULL REFERENCES zello.professionals(id) ON DELETE CASCADE,
    to_specialty text NOT NULL,
    reason text NOT NULL,
    status text NOT NULL DEFAULT 'ativo' CHECK (status IN ('ativo', 'concluido', 'cancelado')),
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_referrals_patient ON zello.referrals(patient_id);
CREATE INDEX idx_referrals_from_professional ON zello.referrals(from_professional_id);

-- =============================================================
-- 3. RLS - session_notes
-- =============================================================
ALTER TABLE zello.session_notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Psicologos podem ver notas dos seus pacientes"
    ON zello.session_notes FOR SELECT
    USING (
        professional_id IN (
            SELECT id FROM zello.professionals WHERE profile_id IN (
                SELECT id FROM zello.profiles WHERE user_id = auth.uid()
            )
        )
        OR
        EXISTS (
            SELECT 1 FROM zello.profiles
            WHERE user_id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "Psicologos podem criar notas"
    ON zello.session_notes FOR INSERT
    WITH CHECK (
        professional_id IN (
            SELECT id FROM zello.professionals WHERE profile_id IN (
                SELECT id FROM zello.profiles WHERE user_id = auth.uid()
            )
        )
        OR
        EXISTS (
            SELECT 1 FROM zello.profiles
            WHERE user_id = auth.uid() AND role = 'admin'
        )
    );

-- =============================================================
-- 4. RLS - referrals
-- =============================================================
ALTER TABLE zello.referrals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Profissionais podem ver encaminhamentos dos seus pacientes"
    ON zello.referrals FOR SELECT
    USING (
        from_professional_id IN (
            SELECT id FROM zello.professionals WHERE profile_id IN (
                SELECT id FROM zello.profiles WHERE user_id = auth.uid()
            )
        )
        OR
        EXISTS (
            SELECT 1 FROM zello.profiles
            WHERE user_id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "Profissionais podem criar encaminhamentos"
    ON zello.referrals FOR INSERT
    WITH CHECK (
        from_professional_id IN (
            SELECT id FROM zello.professionals WHERE profile_id IN (
                SELECT id FROM zello.profiles WHERE user_id = auth.uid()
            )
        )
        OR
        EXISTS (
            SELECT 1 FROM zello.profiles
            WHERE user_id = auth.uid() AND role = 'admin'
        )
    );

-- =============================================================
-- 5. GRANTS
-- =============================================================
GRANT ALL ON zello.session_notes TO service_role;
GRANT SELECT, INSERT ON zello.session_notes TO authenticated;
GRANT ALL ON zello.referrals TO service_role;
GRANT SELECT, INSERT ON zello.referrals TO authenticated;
