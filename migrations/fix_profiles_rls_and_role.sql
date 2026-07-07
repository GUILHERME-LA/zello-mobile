-- =============================================================
-- ZELLO - MIGRATION: Corrigir RLS, coluna de email e trigger de novos usuários
-- Schema: zello
-- =============================================================

-- 1. Garante que a coluna email existe na tabela profiles
ALTER TABLE zello.profiles 
ADD COLUMN IF NOT EXISTS email text;

-- 2. Atualiza os emails dos perfis existentes a partir da tabela auth.users
UPDATE zello.profiles p
SET email = u.email
FROM auth.users u
WHERE p.user_id = u.id AND p.email IS NULL;

-- 3. Recria a função user_role de forma correta e segura (sem recursão e sem prof.user_id)
CREATE OR REPLACE FUNCTION zello.user_role()
RETURNS text
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path = zello, pg_temp
    AS $$
    SELECT COALESCE(
        (SELECT role FROM zello.profiles WHERE user_id = auth.uid()),
        'patient'
    );
$$;

-- 4. Recria a função user_profile_id
CREATE OR REPLACE FUNCTION zello.user_profile_id()
RETURNS uuid
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path = zello, pg_temp
    AS $$
    SELECT id FROM zello.profiles WHERE user_id = auth.uid();
$$;

-- 5. Recria a função user_professional_id
CREATE OR REPLACE FUNCTION zello.user_professional_id()
RETURNS uuid
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path = zello, pg_temp
    AS $$
    SELECT p.id FROM zello.professionals p
    WHERE p.profile_id = zello.user_profile_id();
$$;

-- 6. Recria a função do trigger handle_new_user garantindo inserção no campo email
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
  ON CONFLICT (user_id) DO UPDATE
  SET email = EXCLUDED.email,
      name = COALESCE(zello.profiles.name, EXCLUDED.name);
  RETURN NEW;
END;
$$;

-- 7. Limpa e recria todas as políticas RLS da tabela profiles para remover referências a 'prof.user_id'
DROP POLICY IF EXISTS profiles_admin_rw ON zello.profiles;
DROP POLICY IF EXISTS profiles_select_own ON zello.profiles;
DROP POLICY IF EXISTS profiles_select_professional ON zello.profiles;
DROP POLICY IF EXISTS profiles_select_admin ON zello.profiles;
DROP POLICY IF EXISTS profiles_insert_admin ON zello.profiles;
DROP POLICY IF EXISTS profiles_update_own ON zello.profiles;

CREATE POLICY profiles_admin_rw ON zello.profiles
    FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY profiles_select_own ON zello.profiles
    FOR SELECT TO authenticated 
    USING (user_id = auth.uid());

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
