
  <br/>
  <img alt="Zello Saúde" src="https://img.shields.io/badge/Zello%20Saúde-🏥-6C63FF?style=for-the-badge" />
</div>

# Zello Saúde 🏥

**Aplicativo mobile para gestão de saúde** — plataforma completa com apps para **pacientes** e **administradores**, desenvolvida em **Flutter**.

---

## ✨ Funcionalidades

### 👤 App Paciente
- 📅 **Agendamento de consultas** e exames
- 📋 **Histórico médico** completo
- 💊 **Controle de medicamentos** com lembretes
- 🔔 **Notificações** de procedimentos e retornos
- 🗺️ **Localização** de unidades de saúde

### 🛠️ App Admin
- 👥 **Gestão de pacientes** e prontuários
- 📊 **Dashboard administrativo** com indicadores
- 📅 **Gerenciamento de agenda** de profissionais
- 📈 **Relatórios** e exportação de dados

---

## 🛠️ Stack

<div align="left">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=flat-square&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Supabase-3FCF8E?style=flat-square&logo=supabase&logoColor=white" />
</div>

| Categoria | Tecnologia |
|-----------|------------|
| **Framework** | Flutter |
| **Linguagem** | Dart |
| **Arquitetura** | MVC + Repository Pattern |
| **Estado** | MobX / Riverpod |
| **Backend** | Supabase |
| **Notificações** | Firebase Cloud Messaging |

---

## 🚀 Como Executar Localmente

```bash
# Clone o repositório
git clone https://github.com/GUILHERME-LA/zello-mobile.git

# Acesse a pasta
cd zello-mobile

# Instale as dependências
flutter pub get

# Execute em modo desenvolvimento
flutter run
```

> **Pré-requisitos:** Flutter SDK 3.x instalado e um emulador/dispositivo configurado.

---

## 📂 Estrutura do Projeto

```
zello-mobile/
├── lib/
│   ├── app/              # App Paciente
│   │   ├── modules/      # Módulos por funcionalidade
│   │   └── shared/       # Widgets compartilhados
│   ├── admin/            # App Administrador
│   │   ├── modules/      # Módulos administrativos
│   │   └── shared/       # Widgets compartilhados
│   ├── core/             # Core: temas, rotas, helpers
│   └── main.dart         # Entry point
├── test/                 # Testes unitários e widget
└── pubspec.yaml          # Dependências
```

---

## 📄 Licença

Este projeto é de código aberto para fins educacionais e de portfólio.
