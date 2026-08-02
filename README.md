# ⚽ FootStat Pro - Gerenciador de Torneios & Lives em Flutter + Riverpod

O **FootStat Pro** é uma aplicação completa e multiplataforma desenvolvida em **Flutter** com gerenciamento de estado reativo via **Riverpod** para gerenciamento de torneios de futebol, estatísticas de jogadores em tempo real, compilação de partidas ao vivo e galeria de transmissões (lives e gravações).

---

## 🎨 Design System & Estética Visual

A interface foi projetada em **Material 3** com um tema escuro esportivo premium (*Dark Pitch*):

* **Palette Dark Pitch**: Fundo escuro (`#0B1326`), superfície em container (`#171F33`) e elevação em cartões customizados.
* **Neon Emerald & Badges Coloridas**:
  * **Verde Esmeralda Neon (`#4EDEA3`)**: Ações principais, destaques e botões glow.
  * **Dourado (`#FFD700`)**: Artilharia e prêmios de MVP.
  * **Escarlate (`#FF4D4D`)**: Transmissões ao vivo (Lives), assistências e alertas.
  * **Azul Elétrico (`#3B82F6`)**: Métricas de jogos disputados.

---

## 🚀 Funcionalidades Completas do App Flutter

### 1. 👥 Gestão de Competidores Globais (`competitors_screen.dart`)
* Cadastro, listagem e remoção de jogadores.
* **Renomeação em Cascata**: Ao renomear um jogador global, seu nome é atualizado automaticamente em todos os torneios, rodadas, presenças, MVPs e partidas registradas.

### 2. 🏆 Criação & Gestão de Torneios (`create_tournament_screen.dart` & `tournaments_list_screen.dart`)
* Início de campeonatos com seleção múltipla de participantes.
* Adição dinâmica de novos jogadores a torneios já em andamento.
* Encerramento do torneio com trava de segurança e cálculo dos campeões.

### 3. 📅 Atividades / Rodadas (`activity_details_screen.dart`)
* Criação de rodadas com campos para **Nome** e **Link da Live/Transmissão** (Opcional).
* Marcação da lista de presença da rodada.
* Votação e atribuição do **MVP da rodada**.
* Finalização da atividade.

### 4. 🔴 Módulo de Live Streaming & Vídeos das Partidas (`lives_gallery_screen.dart`)
* Formulário para anexar links de transmissões (YouTube, Twitch, Google Drive, etc.).
* Galeria dedicada de Lives acessível via menu principal.
* Compartilhamento direto dos links para cortes e edições de melhores momentos.

### 5. ⚽ Compilador de Partidas ao Vivo (`register_match_screen.dart`)
* Placar tátil com contadores `+` e `-` para **Gols** e **Assistências** por jogador.
* Gravação com timestamp e recálculo automático de estatísticas.

### 6. 📊 Estatísticas Gerais & Leaderboard (`general_stats_screen.dart`)
* **Histórico Acumulado (Todos os Tempos)**: Ranking geral com pódio (🥇 1º, 🥈 2º, 🥉 3º).
* **Destaques da Temporada**: Badges de Artilheiro 👑, Garçom 👟, Maratonista 🎮 e MVP ⭐.

### 7. 💾 Backup & Integração Excel (`backup_screen.dart`)
* Exportação de dados do torneio em formato `.csv` (compatível com Excel e UTF-8 BOM).
* Importação e restauração de dados de torneios via arquivo `.csv`.

---

## 🏗️ Estrutura do Projeto Flutter (`lib/`)

```text
lib/
├── main.dart                         # Ponto de entrada com ProviderScope e MaterialApp
├── core/
│   ├── constants/
│   │   └── app_colors.dart          # Paleta de cores FootStat Dark Emerald
│   ├── theme/
│   │   └── app_theme.dart           # Tema escuro Material 3 com GoogleFonts
│   └── utils/
│       └── csv_helper.dart          # Gerador e leitor de arquivos CSV
├── domain/
│   └── models/
│       ├── match_stats.dart         # Estatísticas individuais (Gols / Assistências)
│       ├── match_record.dart        # Registro da partida
│       ├── activity.dart            # Atividade/Rodada com liveUrl
│       └── tournament.dart          # Torneio e lista de participantes
├── data/
│   └── repositories/
│       └── storage_repository.dart  # Persistência local JSON com SharedPreferences
└── presentation/
    ├── providers/
    │   ├── players_provider.dart    # StateNotifier dos Competidores Globais + Cascata
    │   └── tournaments_provider.dart# StateNotifier completo de Torneios e Partidas
    ├── screens/
    │   ├── home_screen.dart         # Dashboard principal com Bento Grid e Bento Metrics
    │   ├── competitors_screen.dart  # Gestão de competidores
    │   ├── create_tournament_screen.dart # Cadastro de torneio
    │   ├── tournaments_list_screen.dart  # Meus Torneios
    │   ├── tournament_details_screen.dart# Detalhes e rodadas
    │   ├── activity_details_screen.dart  # Detalhes da rodada, presença e live link
    │   ├── register_match_screen.dart    # Compilador de placar ao vivo (+ / -)
    │   ├── lives_gallery_screen.dart     # Galeria dedicada de transmissões/lives
    │   ├── general_stats_screen.dart     # Rankings acumulados e pódio
    │   └── backup_screen.dart            # Backup e restauração CSV
    └── widgets/
        ├── custom_card.dart          # Container estilizado modo escuro
        ├── primary_button.dart       # Botão de ação estilizado
        └── rank_badge.dart           # Badges coloridas de prêmios
```

---

## 🛠️ Como Executar o App Flutter

Com o SDK do **Flutter** instalado no seu ambiente:

```bash
# 1. Instalar as dependências do pubspec.yaml
flutter pub get

# 2. Executar no Google Chrome ou dispositivo móvel
flutter run -d chrome
```

---
*FootStat Pro © 2026 - Código Flutter limpo, otimizado e pronto para produção.*
