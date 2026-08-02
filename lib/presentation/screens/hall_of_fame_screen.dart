import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/tournaments_provider.dart';
import '../widgets/custom_card.dart';

class HallOfFameScreen extends ConsumerWidget {
  const HallOfFameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournaments = ref.watch(tournamentsProvider);
    final finishedTournaments = tournaments.where((t) => t.isFinished).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('🏛️ Hall da Fama & Galeria de Campeões'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Trophy Banner
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.15),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gold),
                      ),
                      child: const Icon(Icons.emoji_events, color: AppColors.gold, size: 36),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GALERIA DOS CAMPEÕES',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Os grandes vencedores, artilheiros e destaques que marcaram a história dos torneios.',
                            style: TextStyle(
                              color: AppColors.subtext,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (finishedTournaments.isEmpty)
                CustomCard(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: const [
                      Icon(Icons.workspace_premium, color: AppColors.subtext, size: 48),
                      SizedBox(height: 12),
                      Text(
                        'NENHUM TORNEIO FINALIZADO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Quando um torneio for encerrado, os troféus do campeão, artilheiro e MVP aparecerão automaticamente aqui!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.subtext, fontSize: 12),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: finishedTournaments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final t = finishedTournaments[index];

                    // Calculate stats for this finished tournament
                    final totals = <String, Map<String, int>>{};
                    for (final p in t.playerNames) {
                      totals[p] = {'goals': 0, 'assists': 0, 'mvps': 0};
                    }

                    for (final act in t.activities) {
                      if (act.mvp.isNotEmpty && totals.containsKey(act.mvp)) {
                        totals[act.mvp]!['mvps'] = (totals[act.mvp]!['mvps'] ?? 0) + 1;
                      }
                      for (final m in act.matches) {
                        m.stats.forEach((pName, s) {
                          if (totals.containsKey(pName)) {
                            totals[pName]!['goals'] = (totals[pName]!['goals'] ?? 0) + s.goals;
                            totals[pName]!['assists'] = (totals[pName]!['assists'] ?? 0) + s.assists;
                          }
                        });
                      }
                    }

                    String champion = t.playerNames.isNotEmpty ? t.playerNames.first : 'N/A';
                    String topScorer = 'N/A'; int topGoals = 0;
                    String topAssist = 'N/A'; int topAssistsCount = 0;
                    String topMvp = 'N/A'; int topMvpsCount = 0;

                    for (final pName in t.playerNames) {
                      final stat = totals[pName]!;
                      if (stat['goals']! > topGoals) { topGoals = stat['goals']!; topScorer = pName; }
                      if (stat['assists']! > topAssistsCount) { topAssistsCount = stat['assists']!; topAssist = pName; }
                      if (stat['mvps']! > topMvpsCount) { topMvpsCount = stat['mvps']!; topMvp = pName; }
                    }

                    return CustomCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                t.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                                ),
                                child: const Text(
                                  '🏆 TORNEIO ENCERRADO',
                                  style: TextStyle(
                                    color: AppColors.gold,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Hall of fame awards grid
                          Row(
                            children: [
                              Expanded(
                                child: _HallAwardCard(
                                  title: 'CAMPEÃO',
                                  playerName: champion,
                                  subtitle: '🥇 1º Lugar Geral',
                                  color: AppColors.gold,
                                  icon: Icons.emoji_events,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _HallAwardCard(
                                  title: 'ARTILHEIRO',
                                  playerName: topScorer,
                                  subtitle: '⚽ $topGoals Gols',
                                  color: AppColors.primary,
                                  icon: Icons.sports_soccer,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _HallAwardCard(
                                  title: 'GARÇOM',
                                  playerName: topAssist,
                                  subtitle: '👟 $topAssistsCount Assists',
                                  color: AppColors.secondary,
                                  icon: Icons.sports_score,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _HallAwardCard(
                                  title: 'BOLA DE OURO',
                                  playerName: topMvp,
                                  subtitle: '⭐ $topMvpsCount MVPs',
                                  color: AppColors.tertiary,
                                  icon: Icons.star,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

class _HallAwardCard extends StatelessWidget {
  final String title;
  final String playerName;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _HallAwardCard({
    required this.title,
    required this.playerName,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            playerName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.subtext,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
