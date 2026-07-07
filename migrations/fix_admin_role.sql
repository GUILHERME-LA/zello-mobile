-- =============================================================
-- ZELLO - FIX: Corrigir role do admin e permitir cadastro de
--         profissionais (RLS)
-- =============================================================

-- 1. Primeiro, descubra seu user_id no auth.users
--    Rode no SQL Editor do Supabase:
--    SELECT id, email FROM auth.users WHERE email = 'SEU_EMAIL@EMAIL.COM';

-- 2. Depois de descobrir o ID, rode o UPDATE abaixo trocando
--    o 'SEU_USER_ID_AQUI' pelo ID real:
--
-- UPDATE zello.profiles
-- SET role = 'admin'
-- WHERE user_id = 'SEU_USER_ID_AQUI';
--
-- =============================================================

-- Script seguro para evitar erro caso não saiba o user_id:

DO $$
DECLARE
  admin_id uuid;
BEGIN
  -- Tenta encontrar o primeiro admin pelo email (SUBSTITUA pelo seu email)
  admin_id := (SELECT id FROM auth.users WHERE email = 'admin@zellosaude.com' LIMIT 1);

  -- Se não encontrar pelo email, pega o primeiro usuário da tabela auth.users
  IF admin_id IS NULL THEN
    admin_id := (SELECT id FROM auth.users ORDER BY created_at ASC LIMIT 1);
  END IF;

  IF admin_id IS NOT NULL THEN
    -- Cria o profile se não existir, ou atualiza a role
    INSERT INTO zello.profiles (user_id, role, name, email)
    VALUES (admin_id, 'admin', 'Administrador', (SELECT email FROM auth.users WHERE id = admin_id))
    ON CONFLICT (user_id) DO UPDATE
    SET role = 'admin';
    
    RAISE NOTICE '✅ Admin role configurada para user_id: %', admin_id;
  ELSE
    RAISE NOTICE '❌ Nenhum usuário encontrado. Crie um admin manualmente.';
  END IF;
END $$;
