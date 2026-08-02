import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/players_provider.dart';
import '../providers/tournaments_provider.dart';
import '../widgets/custom_card.dart';
import 'competitors_screen.dart';
import 'create_tournament_screen.dart';
import 'tournaments_list_screen.dart';
import 'general_stats_screen.dart';
import 'lives_gallery_screen.dart';
import 'backup_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalPlayers = ref.watch(playersProvider);
    final tournaments = ref.watch(tournamentsProvider);

    int totalGoals = 0;
    for (final t in tournaments) {
      for (final act in t.activities) {
        for (final m in act.matches) {
          m.stats.forEach((_, s) {
            totalGoals += s.goals;
          });
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚽ FootStat Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: AppColors.danger),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LivesGalleryScreen()),
              );
            },
            tooltip: 'Lives & Transmissões',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Banner Card
              CustomCard(
                backgroundColor: AppColors.cardSecondary,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sports_soccer,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Gerenciador de Torneios & Lives',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                          ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Placar ao vivo, gols, assistências, MVPs e gravações de cada rodada.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.subtext,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Metric Cards (Bento Grid)
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'Competidores',
                      value: '${globalPlayers.length}',
                      icon: Icons.groups,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      title: 'Torneios',
                      value: '${tournaments.length}',
                      icon: Icons.emoji_events,
                      color: AppColors.badgeMatches,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      title: 'Gols Salvos',
                      value: '$totalGoals',
                      icon: Icons.sports_soccer,
                      color: AppColors.badgeGoals,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Menu Principal',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _MenuTile(
                icon: Icons.people_outline,
                title: 'Gerenciar Competidores',
                subtitle: 'Cadastrar, renomear em cascata e excluir jogadores',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CompetitorsScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              _MenuTile(
                icon: Icons.add_circle_outline,
                title: 'Criar Novo Torneio',
                subtitle: 'Iniciar um campeonato escolhendo participantes',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateTournamentScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              _MenuTile(
                icon: Icons.emoji_events_outlined,
                title: 'Meus Torneios',
                subtitle: 'Visualizar rodadas, incluir jogadores e salvar partidas',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TournamentsListScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              _MenuTile(
                icon: Icons.videocam_outlined,
                iconColor: AppColors.danger,
                title: 'Lives & Gravações',
                subtitle: 'Galeria com transmissões e vídeos gravados dos jogos',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LivesGalleryScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              _MenuTile(
                icon: Icons.bar_chart,
                title: 'Estatísticas Gerais',
                subtitle: 'Ranking acumulado de todos os tempos e por temporada',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GeneralStatsScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              _MenuTile(
                icon: Icons.save_alt,
                title: 'Backup (Excel / CSV)',
                subtitle: 'Exportar estatísticas ou importar arquivo CSV',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BackupScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.subtext,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;

    return CustomCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.subtext,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.subtext,
            size: 20,
          ),
        ],
      ),
    );
  }
}
