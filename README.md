# Zello Saúde

> Plataforma unificada de gestão de saúde que conecta pacientes, profissionais e administradores em um ecossistema com prontuário eletrônico, IA e backend serverless.

[![Flutter](https://img.shields.io/badge/Flutter-3.32.0-blue.svg)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E.svg)](https://supabase.com)
[![License](https://img.shields.io/badge/license-Proprietário-red.svg)](#licença)

---

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Funcionalidades](#funcionalidades)
- [Arquitetura](#arquitetura)
- [Tecnologias](#tecnologias)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Pré-requisitos](#pré-requisitos)
- [Configuração do Ambiente](#configuração-do-ambiente)
- [Executando o Projeto](#executando-o-projeto)
- [Banco de Dados](#banco-de-dados)
- [Variáveis de Ambiente](#variáveis-de-ambiente)
- [CI/CD](#cicd)
- [Status do Build](#status-do-build)
- [Contribuindo](#contribuindo)

---

## Visão Geral

O **Zello Saúde** é uma plataforma de gestão de saúde que resolve a fragmentação de dados clínicos, oferecendo um prontuário eletrônico unificado com análises inteligentes via Inteligência Artificial. O sistema atende quatro perfis de usuário com fluxos dedicados:

| Perfil | Descrição |
|--------|-----------|
| **Paciente** | Gerencia sua saúde, importa prontuários, agenda consultas e conversa com a IA |
| **Profissional (Médico)** | Atende pacientes, prescreve medicamentos e solicita exames |
| **Profissional (Psicólogo)** | Realiza sessões, registra evolução e faz encaminhamentos |
| **Administrador** | Gerencia profissionais, configura o sistema e monitora métricas |

### Problemas que o Zello resolve

- **Fragmentação de dados de saúde** entre profissionais e instituições
- **Falta de visão holística** do histórico do paciente
- **Gestão ineficiente de convênios** e planos de saúde
- **Prontuários em papel** com risco de perda e difícil compartilhamento
- **Ausência de IA** para análises preditivas e recomendações

---

## Funcionalidades

### Módulos do Paciente
- **Prontuário Eletrônico** — histórico completo, importação de documentos (PDF/Imagem/TXT) com extração via IA
- **Análise de Prontuário por IA** — insights e resumos do histórico de saúde
- **Consultas & Agenda** — agendamento e acompanhamento
- **Exames** — visualização e status de solicitações
- **Medicamentos** — cadastro e acompanhamento de tratamento
- **Convênios** — análise IA de planos e recomendação de hospitais
- **AI Hub** — hub central de ferramentas de inteligência
- **Chat com IA** — agente conversacional para dúvidas de saúde

### Módulos do Profissional / Admin
- **Dashboard** — métricas e atividade recente
- **Gestão de Pacientes** — CRUD completo com dados demográficos
- **Gestão de Profissionais** — controle de permissões e disponibilidade
- **Solicitações de Exames** — criação e acompanhamento de status
- **Detalhe de Conversas** — histórico de interações com pacientes
- **Configurações & Agentes** — configuração do sistema e agentes de IA

---

## Arquitetura

Arquitetura **Mobile-First com Backend como Serviço (BaaS)**:

```
┌──────────────────────────── FRONTEND (Flutter) ───────────────────────────┐
│   zello_app (App Admin/Profissional/Paciente)  │  zello_shared (lib)       │
└───────────────────────────────┬──────────────────────────────────────────┘
                                 │  Supabase Client / REST
                                 ▼
┌──────────────────────────── BACKEND (Supabase) ──────────────────────────┐
│  PostgreSQL  │  Auth (JWT)  │  Realtime  │  Edge Functions (Deno/TS)       │
└───────┬──────────────────────────┬───────────────────────────────────────┘
        │                          │
   ┌────▼─────┐              ┌─────▼──────┐
   │  n8n     │              │ Anthropic  │
   │ (webhooks)│              │ Claude API │
   └──────────┘              └────────────┘
```

| Aspecto | Padrão |
|---------|--------|
| **Arquitetura** | Feature-Based (cada funcionalidade é um módulo) |
| **State Management** | Riverpod (`StateNotifier` + `FutureProvider`) |
| **Routing** | GoRouter com redirects baseados em role |
| **Design System** | Custom (`ZelloTheme` + Material 3) |
| **Shared Code** | Biblioteca compartilhada `zello_shared` |
| **API Pattern** | Supabase Client direto + webhooks n8n legados |
| **IA** | Anthropic Claude (cloud) + Ollama (local) |

---

## Tecnologias

| Tecnologia | Versão | Propósito |
|------------|--------|-----------|
| **Flutter** | 3.32.0 | Framework multiplataforma (Android/iOS/Web) |
| **Dart** | 3.7.2+ | Linguagem |
| **flutter_riverpod** | ^2.6.0 | State management |
| **go_router** | ^14.0.0 | Roteamento com guards por perfil |
| **supabase_flutter** | ^2.8.4 | Backend (Auth, DB, Realtime) |
| **google_fonts** | ^6.2.0 | Tipografia |
| **google_maps_flutter** | ^2.10.0 | Localização de hospitais |
| **syncfusion_flutter_charts** | ^28.0.0 | Gráficos de saúde |
| **pdf** / **printing** | ^3.11 / ^5.13 | Geração e impressão de relatórios |
| **lucide_icons** | ^0.257.0 | Ícones |

**Backend & Infra**
- **Supabase** — PostgreSQL + Auth (JWT) + Realtime + Edge Functions (Deno/TypeScript)
- **n8n** — orquestração de automações e webhooks legados
- **Anthropic Claude** — inferência de IA na nuvem
- **Ollama** — inferência de IA local (opcional)

---

## Estrutura do Projeto

```
zello/
├── zello_app/                 # App Flutter principal (Admin, Profissional, Paciente)
│   ├── lib/
│   │   ├── core/              # Shells, router, tema, inicialização
│   │   └── features/          # Módulos por funcionalidade
│   │       ├── admin/         # dashboard, pacientes, profissionais, agentes...
│   │       ├── auth/          # login (admin/profissional e paciente)
│   │       ├── patient/       # home, prontuário, exames, agenda, chat...
│   │       └── ai_hub/        # hub de inteligência
│   ├── test/                  # testes (widget smoke test)
│   └── pubspec.yaml
├── zello_shared/              # Biblioteca compartilhada (models, API client, tema, providers)
│   └── lib/
│       ├── core/              # api, theme, demo_data, notifications
│       ├── models/            # modelos de domínio (exam, etc.)
│       ├── providers/         # Riverpod providers
│       └── zello_shared.dart
├── supabase/                  # Configuração do backend
│   ├── functions/             # Edge Functions (Deno/TS) — ex: chat-qa
│   └── migrations/            # SQL de schema do banco
├── migrations/                # Snapshots de migrações SQL
├── docs/                      # Documentação do projeto
├── codemagic.yaml             # Pipeline de CI/CD (Android)
├── .fvmrc                     # Versão fixa do Flutter (3.32.0)
└── .gitignore
```

---

## Pré-requisitos

- **Flutter SDK 3.32.0** (gerenciado via [fvm](https://fvm.app) — veja `.fvmrc`)
- **Dart 3.7.2+**
- **Conta Supabase** (projeto com as migrações aplicadas)
- **Chave de API Anthropic** (para funcionalidades de IA)
- Git

---

## Configuração do Ambiente

1. **Clone o repositório**
   ```bash
   git clone https://github.com/Honorix-ia/zello.git
   cd zello
   ```

2. **Instale a versão correta do Flutter (via fvm)**
   ```bash
   dart pub global activate fvm
   fvm install            # usa a versão do .fvmrc (3.32.0)
   ```

3. **Configure as variáveis de ambiente**
   Crie um arquivo `.env` na raiz de `zello_app/` (veja [Variáveis de Ambiente](#variáveis-de-ambiente)).

4. **Aplique as migrações do banco**
   ```bash
   supabase db push       # ou execute os SQL em supabase/migrations/
   ```

5. **Instale as dependências**
   ```bash
   fvm flutter pub get
   ```

---

## Executando o Projeto

### Web (desenvolvimento)
```bash
cd zello_app
fvm flutter run -d chrome
```

### Android / iOS
```bash
cd zello_app
fvm flutter run
```

### Build de produção (Web)
```bash
cd zello_app
fvm flutter build web --release
```

### Testes
```bash
cd zello_app
fvm flutter test
```
> ⚠️ O smoke test instancia o app completo e requer credenciais do Supabase configuradas no ambiente.

---

## Banco de Dados

O schema é gerenciado via **migrações SQL** versionadas em `supabase/migrations/` e `migrations/`:

| Migração | Conteúdo |
|----------|----------|
| `2025_07_02_core_tables.sql` | Tabelas centrais (pacientes, profissionais, usuários) |
| `2025_07_07_prontuario.sql` | Prontuário eletrônico |
| `2026_07_10_ai_hub.sql` | Módulo de IA / AI Hub |
| `2026_07_10_therapies_treatments_anamneses.sql` | Terapias, tratamentos e anamneses |

A segurança é garantida por **Row Level Security (RLS)** — cada usuário acessa apenas seus dados.

---

## Variáveis de Ambiente

Crie um arquivo `.env` em `zello_app/` (ele já está no `.gitignore`):

```env
SUPABASE_URL=https://SEU_PROJETO.supabase.co
SUPABASE_ANON_KEY=SUA_CHAVE_ANON
ANTHROPIC_API_KEY=sua_chave_anthropic
# OLLAMA_HOST=http://localhost:11434   # opcional, para IA local
```

| Variável | Obrigatória | Descrição |
|----------|-------------|-----------|
| `SUPABASE_URL` | Sim | URL do projeto Supabase |
| `SUPABASE_ANON_KEY` | Sim | Chave pública (anon) do Supabase |
| `ANTHROPIC_API_KEY` | Sim* | Chave da API Claude para recursos de IA |
| `OLLAMA_HOST` | Não | Endpoint Ollama para IA local |

*\* Necessária apenas para funcionalidades de IA na nuvem.

---

## CI/CD

O pipeline de build Android é configurado em [`codemagic.yaml`](codemagic.yaml) com dois workflows:
- **zello-app** — APK de debug (`com.zellosaude.patient`)
- **admin-app** — APK de debug (`com.zellosaude.admin`)

Ambos usam `flutter: 3.29.2` no CI (alinhável ao `.fvmrc` local via fvm).

---

## Status do Build

| Check | Status |
|-------|--------|
| `flutter analyze` | ✅ 0 erros |
| `flutter build web --release` | ✅ Compila (Flutter 3.32.0) |
| `flutter test` | ⚠️ Requer backend Supabase configurado |

---

## Contribuindo

1. Crie uma branch a partir de `main`: `git checkout -b feature/nome-da-feature`
2. Siga o padrão **Feature-Based** e use **Riverpod** para estado
3. Mantenha o `flutter analyze` sem erros
4. Abra um Pull Request descrevendo as mudanças

---

## Licença

Projeto proprietário — **Honorix**. Todos os direitos reservados.

---

<div align="center">
  <sub>Desenvolvido por <strong>Honorix</strong> · empresahonorix@gmail.com</sub>
</div>
