-- 1. Adiciona a coluna de status na tabela de exames se ela não existir
ALTER TABLE zello.exams 
ADD COLUMN IF NOT EXISTS status text DEFAULT 'pending';

-- 2. Garante que a policy de UPDATE permita que o profissional altere o status do exame
DROP POLICY IF EXISTS exams_update_professional ON zello.exams;
CREATE POLICY exams_update_professional ON zello.exams
    FOR UPDATE TO authenticated
    USING (zello.user_role() IN ('admin', 'professional'))
    WITH CHECK (zello.user_role() IN ('admin', 'professional'));