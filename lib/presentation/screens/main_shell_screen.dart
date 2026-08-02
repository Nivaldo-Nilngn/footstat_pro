import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/players_provider.dart';
import '../providers/tournaments_provider.dart';
import '../widgets/custom_card.dart';
import 'competitors_screen.dart';
import 'create_tournament_screen.dart';
import 'tournaments_list_screen.dart';
import 'lives_gallery_screen.dart';
import 'general_stats_screen.dart';
import 'backup_screen.dart';

enum ActiveTab {
  dashboard,
  competitors,
  tournaments,
  lives,
  stats,
  backup,
  createTournament,
}

final activeTabProvider = StateProvider<ActiveTab>((ref) => ActiveTab.dashboard);

class MainShellScreen extends ConsumerWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(activeTabProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: AppColors.cardBackground,
              elevation: 0,
              title: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                    ),
                    child: const Icon(
                      Icons.sports_soccer,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      children: [
                        TextSpan(text: 'FootStat ', style: TextStyle(color: Colors.white)),
                        TextSpan(text: 'Pro', style: TextStyle(color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () => ref.read(activeTabProvider.notifier).state = ActiveTab.lives,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.danger.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.danger,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '🔴 LIVES',
                            style: TextStyle(
                              color: AppColors.danger,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      body: Row(
        children: [
          if (isDesktop) const _DesktopSidebar(),
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _buildActiveScreen(activeTab, ref),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : const _MobileBottomBar(),
    );
  }

  Widget _buildActiveScreen(ActiveTab tab, WidgetRef ref) {
    switch (tab) {
      case ActiveTab.dashboard:
        return const DashboardView();
      case ActiveTab.competitors:
        return const CompetitorsScreen();
      case ActiveTab.tournaments:
        return const TournamentsListScreen();
      case ActiveTab.lives:
        return const LivesGalleryScreen();
      case ActiveTab.stats:
        return const GeneralStatsScreen();
      case ActiveTab.backup:
        return const BackupScreen();
      case ActiveTab.createTournament:
        return const CreateTournamentScreen();
    }
  }
}

class _DesktopSidebar extends ConsumerWidget {
  const _DesktopSidebar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(activeTabProvider);

    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Branding
          InkWell(
            onTap: () => ref.read(activeTabProvider.notifier).state = ActiveTab.dashboard,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                  ),
                  child: const Icon(
                    Icons.sports_soccer,
                    size: 24,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                        children: [
                          TextSpan(text: 'FootStat ', style: TextStyle(color: Colors.white)),
                          TextSpan(text: 'Pro', style: TextStyle(color: AppColors.primary)),
                        ],
                      ),
                    ),
                    const Text(
                      'ELITE FOOTBALL ANALYTICS',
                      style: TextStyle(
                        color: AppColors.subtext,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Primary Quick Action Button
          ElevatedButton.icon(
            onPressed: () => ref.read(activeTabProvider.notifier).state = ActiveTab.createTournament,
            icon: const Icon(Icons.add_circle, color: Colors.black, size: 20),
            label: const Text('Novo Torneio'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
            ),
          ),
          const SizedBox(height: 24),

          // Navigation Links
          Expanded(
            child: ListView(
              children: [
                _SidebarNavBtn(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  isSelected: activeTab == ActiveTab.dashboard,
                  onTap: () => ref.read(activeTabProvider.notifier).state = ActiveTab.dashboard,
                ),
                _SidebarNavBtn(
                  icon: Icons.groups_outlined,
                  label: 'Competidores',
                  isSelected: activeTab == ActiveTab.competitors,
                  onTap: () => ref.read(activeTabProvider.notifier).state = ActiveTab.competitors,
                ),
                _SidebarNavBtn(
                  icon: Icons.emoji_events_outlined,
                  label: 'Meus Torneios',
                  isSelected: activeTab == ActiveTab.tournaments,
                  onTap: () => ref.read(activeTabProvider.notifier).state = ActiveTab.tournaments,
                ),
                _SidebarNavBtn(
                  icon: Icons.videocam_outlined,
                  label: 'Lives & Gravações',
                  isSelected: activeTab == ActiveTab.lives,
                  isDanger: true,
                  onTap: () => ref.read(activeTabProvider.notifier).state = ActiveTab.lives,
                ),
                _SidebarNavBtn(
                  icon: Icons.leaderboard_outlined,
                  label: 'Estatísticas Gerais',
                  isSelected: activeTab == ActiveTab.stats,
                  onTap: () => ref.read(activeTabProvider.notifier).state = ActiveTab.stats,
                ),
                _SidebarNavBtn(
                  icon: Icons.save_alt_outlined,
                  label: 'Backup (Excel / CSV)',
                  isSelected: activeTab == ActiveTab.backup,
                  onTap: () => ref.read(activeTabProvider.notifier).state = ActiveTab.backup,
                ),
              ],
            ),
          ),

          // Footer Badge
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border.withOpacity(0.6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Sistema Ativo',
                      style: TextStyle(color: AppColors.subtext, fontSize: 11),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    'v2.7 Pro',
                    style: TextStyle(
                      color: AppColors.subtext,
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDanger;
  final VoidCallback onTap;

  const _SidebarNavBtn({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.isDanger = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor = AppColors.subtext;
    Color bgColor = Colors.transparent;
    Color borderColor = Colors.transparent;

    if (isSelected) {
      textColor = isDanger ? AppColors.danger : AppColors.primary;
      bgColor = isDanger ? AppColors.danger.withOpacity(0.12) : AppColors.primary.withOpacity(0.12);
      borderColor = isDanger ? AppColors.danger.withOpacity(0.3) : AppColors.primary.withOpacity(0.3);
    } else if (isDanger) {
      textColor = AppColors.danger;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? textColor : (isDanger ? AppColors.danger : Colors.white),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileBottomBar extends ConsumerWidget {
  const _MobileBottomBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(activeTabProvider);

    int getIndex(ActiveTab tab) {
      switch (tab) {
        case ActiveTab.dashboard:
          return 0;
        case ActiveTab.competitors:
          return 1;
        case ActiveTab.tournaments:
          return 2;
        case ActiveTab.lives:
          return 3;
        case ActiveTab.stats:
          return 4;
        default:
          return 0;
      }
    }

    return BottomNavigationBar(
      currentIndex: getIndex(activeTab),
      onTap: (index) {
        final tabs = [
          ActiveTab.dashboard,
          ActiveTab.competitors,
          ActiveTab.tournaments,
          ActiveTab.lives,
          ActiveTab.stats,
        ];
        ref.read(activeTabProvider.notifier).state = tabs[index];
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), label: 'Jogadores'),
        BottomNavigationBarItem(icon: Icon(Icons.emoji_events_outlined), label: 'Torneios'),
        BottomNavigationBarItem(icon: Icon(Icons.videocam_outlined), label: 'Lives'),
        BottomNavigationBarItem(icon: Icon(Icons.leaderboard_outlined), label: 'Stats'),
      ],
    );
  }
}

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

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

    final isWide = MediaQuery.of(context).size.width >= 700;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Banner
          CustomCard(
            backgroundColor: AppColors.cardBackground,
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.danger.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Live Streaming & Registro de Partidas',
                        style: TextStyle(
                          color: AppColors.danger,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Gerencie Torneios, Rodadas & Transmissões Ao Vivo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Cadastre competidores, monte campeonatos, conte gols e assistências em tempo real e adicione os links das lives/gravações das partidas de cada dia para rever e fazer cortes!',
                  style: TextStyle(
                    color: AppColors.subtext,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => ref.read(activeTabProvider.notifier).state = ActiveTab.createTournament,
                      icon: const Icon(Icons.add_circle, color: Colors.black, size: 20),
                      label: const Text('Criar Torneio'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => ref.read(activeTabProvider.notifier).state = ActiveTab.lives,
                      icon: const Icon(Icons.videocam, color: AppColors.danger, size: 20),
                      label: const Text('Ver Lives das Partidas', style: TextStyle(color: AppColors.danger)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.danger.withOpacity(0.5)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Bento Grid Metric Cards
          if (isWide)
            Row(
              children: [
                Expanded(
                  child: _BentoMetricCard(
                    title: 'COMPETIDORES GLOBAIS',
                    value: '${globalPlayers.length}',
                    subtitle: 'Jogadores Ativos',
                    icon: Icons.groups,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _BentoMetricCard(
                    title: 'TORNEIOS CADASTRADOS',
                    value: '${tournaments.length}',
                    subtitle: 'Campeonatos',
                    icon: Icons.emoji_events,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _BentoMetricCard(
                    title: 'TOTAL DE GOLS REGISTRADOS',
                    value: '$totalGoals',
                    subtitle: 'Gols Acumulados',
                    icon: Icons.sports_soccer,
                    color: AppColors.gold,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _BentoMetricCard(
                  title: 'COMPETIDORES GLOBAIS',
                  value: '${globalPlayers.length}',
                  subtitle: 'Jogadores Ativos',
                  icon: Icons.groups,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                _BentoMetricCard(
                  title: 'TORNEIOS CADASTRADOS',
                  value: '${tournaments.length}',
                  subtitle: 'Campeonatos',
                  icon: Icons.emoji_events,
                  color: AppColors.secondary,
                ),
                const SizedBox(height: 12),
                _BentoMetricCard(
                  title: 'TOTAL DE GOLS REGISTRADOS',
                  value: '$totalGoals',
                  subtitle: 'Gols Acumulados',
                  icon: Icons.sports_soccer,
                  color: AppColors.gold,
                ),
              ],
            ),
          const SizedBox(height: 28),

          // Quick Access Header
          Row(
            children: const [
              Icon(Icons.apps, color: AppColors.primary, size: 22),
              SizedBox(width: 8),
              Text(
                'Acesso Rápido',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Access Grid Cards
          GridView.count(
            crossAxisCount: isWide ? 4 : 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: isWide ? 1.3 : 1.1,
            children: [
              _QuickCard(
                icon: Icons.person_add,
                title: 'Competidores',
                description: 'Cadastrar, renomear e excluir jogadores globais.',
                color: AppColors.primary,
                onTap: () => ref.read(activeTabProvider.notifier).state = ActiveTab.competitors,
              ),
              _QuickCard(
                icon: Icons.add_circle,
                title: 'Criar Torneio',
                description: 'Monte um novo campeonato com participantes.',
                color: AppColors.primary,
                onTap: () => ref.read(activeTabProvider.notifier).state = ActiveTab.createTournament,
              ),
              _QuickCard(
                icon: Icons.emoji_events,
                title: 'Meus Torneios',
                description: 'Gerencie rodadas, partidas e encerre campeonatos.',
                color: AppColors.secondary,
                onTap: () => ref.read(activeTabProvider.notifier).state = ActiveTab.tournaments,
              ),
              _QuickCard(
                icon: Icons.videocam,
                title: 'Lives & Gravações',
                description: 'Assista às transmissões e vídeos das partidas.',
                color: AppColors.danger,
                onTap: () => ref.read(activeTabProvider.notifier).state = ActiveTab.lives,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BentoMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _BentoMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.subtext,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(icon, color: color, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Icon(Icons.arrow_forward, color: AppColors.subtext, size: 18),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.subtext,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
