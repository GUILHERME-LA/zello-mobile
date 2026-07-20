-- =============================================================
-- TABELA ai_hub (histórico do Hub de IA: perguntas, análises de
-- exame e análises de plano/convenio). Dados persistem para
-- serem visualizados posteriormente pelo usuário.
-- =============================================================

CREATE TABLE IF NOT EXISTS zello.ai_hub (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    owner_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    role text,
    kind text,                 -- 'qa' | 'exam' | 'plan'
    input_text text,
    file_meta jsonb,           -- { name, mime }
    ai_reply text,
    created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_ai_hub_owner
    ON zello.ai_hub(owner_id, created_at DESC);

ALTER TABLE zello.ai_hub ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS ai_hub_select_own ON zello.ai_hub;
CREATE POLICY ai_hub_select_own ON zello.ai_hub
    FOR SELECT USING (auth.uid() = owner_id);

DROP POLICY IF EXISTS ai_hub_insert_own ON zello.ai_hub;
CREATE POLICY ai_hub_insert_own ON zello.ai_hub
    FOR INSERT WITH CHECK (auth.uid() = owner_id);

GRANT SELECT, INSERT ON zello.ai_hub TO authenticated;
GRANT ALL ON zello.ai_hub TO service_role;
