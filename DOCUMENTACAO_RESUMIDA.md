# Zello Saúde — Documentação Resumida

> Plataforma de gestão de saúde com prontuário eletrônico, IA e backend serverless.

---

## 1. Stack Tecnológica

| Camada | Tecnologia | Versão |
|--------|------------|--------|
| **Mobile/Web** | Flutter (Dart) | 3.32.0 |
| **State** | flutter_riverpod + go_router | ^2.6 / ^14.0 |
| **Backend** | Supabase (PostgreSQL + Edge Functions + Auth) | — |
| **IA** | Anthropic Claude (cloud) + Ollama (local) | — |
| **Ícones** | lucide_icons | ^0.257.0 |
| **Gráficos** | syncfusion_flutter_charts | ^28.0.0 |
| **Mapas** | google_maps_flutter | ^2.10.0 |
| **PDF** | pdf + printing | ^3.11 / ^5.13 |

---

## 2. Estrutura do Projeto

```
zello/
├── zello_app/                 # App principal (Admin + Paciente)
│   ├── lib/
│   │   ├── core/              # admin_shell, patient_shell, router
│   │   └── features/
│   │       ├── admin/         # dashboard, pacientes, profissionais, agenda,
│   │       │                  # agentes, conversas, exames, hospitais, settings
│   │       ├── auth/          # login, sign_up (admin e paciente)
│   │       ├── patient/       # home, prontuário, exames, consultas, agenda,
│   │       │                  # medicamentos, convênio, terapias, tratamentos,
│   │       │                  # anamnese, hospitais, perfil, settings
│   │       └── ai_hub/        # hub central de inteligência
│   └── pubspec.yaml
├── zello_shared/              # Biblioteca compartilhada
│   └── lib/
│       ├── core/              # api client, tema, notificações, supabase config,
│       │                      # constantes, utils, demo_data
│       ├── models/            # 29 modelos de domínio
│       ├── providers/         # 29 Riverpod providers
│       └── widgets/           # 11 widgets reutilizáveis
├── supabase/
│   ├── functions/             # 4 Edge Functions (Deno/TypeScript)
│   └── migrations/            # 2 migrações SQL
├── migrations/                # 11 snapshots de migrações SQL
├── vercel.json                # Deploy Flutter Web
├── build.sh                   # Script de build Vercel
├── codemagic.yaml             # CI/CD Android
└── .fvmrc                     # Flutter 3.32.0
```

---

## 3. Perfis de Usuário

| Perfil | Acesso |
|--------|--------|
| **Paciente** | Home, prontuário, exames, agenda, medicamentos, convênio, terapias, tratamentos, chat IA, perfil |
| **Profissional (Médico/Psicólogo)** | Dashboard, pacientes, agenda, solicitações, prontuário do paciente |
| **Administrador** | Dashboard, profissionais, pacientes, configurações, agentes, conversas, exames |

---

## 4. Funcionalidades Principais

- **Prontuário Eletrônico** — histórico completo do paciente com importação de documentos (PDF/Imagem/TXT) e extração via IA
- **AI Hub** — central de ferramentas de inteligência artificial
- **Chat com IA** — agente conversacional para dúvidas de saúde
- **Análise de Convênio** — recomendação de planos e hospitais via IA
- **Agenda** — gestão de consultas e disponibilidade
- **Exames** — solicitação e acompanhamento de status
- **Medicamentos** — cadastro e controle de tratamento
- **Terapias, Tratamentos e Anamnese** — módulos clínicos completos
- **Dashboard** — métricas e atividade recente (admin/profissional)
- **LGPD** — controle de consentimento e exportação de dados

---

## 5. Modelos de Dados (29)

Agent, AI Analysis Result, AI Recommendation, Allergy, Anamnesis, Consultation, Conversation, Dashboard Stats, Exam, Health Profile, Hospital, Hospitalization, Insurance, Medication, Message, Patient, Permission, Professional, Professional Availability, Prontuario Analysis/Import Result, Referral, Session Note, Surgery, Symptom, Therapy, Treatment, User, Vaccine

---

## 6. Providers Riverpod (29)

agents, ai_analysis, ai_recommendations, anamneses, api_client, auth, consultations, conversation_messages, conversations, dashboard, exams, filtered_professionals, hospitals, insurances, medications, patient_consultations, patient_health, patient_medications, patients, permissions, professional_availability, professionals, prontuario_analysis, prontuario_import, referrals, session_notes, supabase_client, therapies, treatments

---

## 7. Edge Functions (4)

| Função | Descrição |
|--------|-----------|
| `chat-qa` | Chat com IA do paciente |
| `analyze-convenio` | Análise de convênios/hospitais |
| `analyze-prontuario` | Análise inteligente de prontuário |
| `import-prontuario` | Importação de documentos com extração IA |

---

## 8. Banco de Dados (Migrações)

| Migração | Tabelas |
|----------|---------|
| `core_tables` | Profiles, patients, professionals, permissions, users |
| `prontuario` | Prontuário eletrônico |
| `clinical_features` | Recursos clínicos |
| `ai_hub` | AI Hub |
| `therapies_treatments_anamneses` | Terapias, tratamentos, anamneses |
| `permissions_system` | Sistema de permissões e RLS |
| `exams_status_policy` | Status de exames |

---

## 9. Deploy

| Plataforma | URL |
|------------|-----|
| **Vercel (Web)** | https://zello-saude.vercel.app |
| **GitHub** | https://github.com/Honorix-ia/zello |

**Vercel:** Build via `build.sh` (instala Flutter 3.32.0 e compila web), output em `zello_app/build/web`. SPA rewrites configurados.

---

## 10. Variáveis de Ambiente (`.env` em `zello_app/`)

```env
SUPABASE_URL=https://SEU_PROJETO.supabase.co
SUPABASE_ANON_KEY=SUA_CHAVE_ANON
ANTHROPIC_API_KEY=sua_chave_anthropic
# OLLAMA_HOST=http://localhost:11434
```

---

## 11. Como Rodar

```bash
git clone https://github.com/Honorix-ia/zello.git
cd zello
dart pub global activate fvm
fvm install         # Flutter 3.32.0
cd zello_app
fvm flutter pub get
fvm flutter run -d chrome    # web
fvm flutter run              # android/ios
```

---

## 12. Status do Build

| Check | Resultado |
|-------|-----------|
| `flutter analyze` | ✅ Sem erros |
| `flutter build web --release` | ✅ Compila |
| `flutter test` | ⚠️ Requer backend Supabase |
