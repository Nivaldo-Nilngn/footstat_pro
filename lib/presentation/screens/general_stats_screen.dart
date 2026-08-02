import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/players_provider.dart';
import '../providers/tournaments_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/rank_badge.dart';

class GeneralStatsScreen extends ConsumerStatefulWidget {
  const GeneralStatsScreen({super.key});

  @override
  ConsumerState<GeneralStatsScreen> createState() => _GeneralStatsScreenState();
}

class _GeneralStatsScreenState extends ConsumerState<GeneralStatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('📊 Estatísticas Gerais & Analytics'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.subtext,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          labelPadding: const EdgeInsets.symmetric(horizontal: 12),
          tabs: const [
            Tab(text: 'Histórico'),
            Tab(text: 'Gráficos'),
            Tab(text: 'Por Torneio'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AllTimeHistoryTab(),
          _AnalyticsChartsTab(),
          _ByTournamentTab(),
        ],
      ),
    );
  }
}

class _AllTimeHistoryTab extends ConsumerWidget {
  const _AllTimeHistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalPlayers = ref.watch(playersProvider);
    final tournaments = ref.watch(tournamentsProvider);

    final globalTotals = <String, Map<String, int>>{};
    for (final p in globalPlayers) {
      globalTotals[p] = {'matches': 0, 'goals': 0, 'assists': 0, 'mvps': 0};
    }

    for (final t in tournaments) {
      for (final act in t.activities) {
        if (act.mvp.isNotEmpty) {
          globalTotals.putIfAbsent(act.mvp, () => {'matches': 0, 'goals': 0, 'assists': 0, 'mvps': 0});
          globalTotals[act.mvp]!['mvps'] = (globalTotals[act.mvp]!['mvps'] ?? 0) + 1;
        }

        for (final pName in act.participants) {
          globalTotals.putIfAbsent(pName, () => {'matches': 0, 'goals': 0, 'assists': 0, 'mvps': 0});
          globalTotals[pName]!['matches'] = (globalTotals[pName]!['matches'] ?? 0) + 1;
        }

        for (final m in act.matches) {
          m.stats.forEach((pName, s) {
            globalTotals.putIfAbsent(pName, () => {'matches': 0, 'goals': 0, 'assists': 0, 'mvps': 0});
            globalTotals[pName]!['goals'] = (globalTotals[pName]!['goals'] ?? 0) + s.goals;
            globalTotals[pName]!['assists'] = (globalTotals[pName]!['assists'] ?? 0) + s.assists;
          });
        }
      }
    }

    final sortedPlayers = globalTotals.keys.toList()
      ..sort((a, b) => globalTotals[b]!['goals']!.compareTo(globalTotals[a]!['goals']!));

    if (sortedPlayers.isEmpty) {
      return const Center(
        child: Text('Nenhum dado cadastrado ainda.', style: TextStyle(color: AppColors.subtext)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Ranking Acumulado de Todos os Tempos',
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            'Soma de todos os jogos, gols, assistências e MVPs obtidos em todos os torneios.',
            style: TextStyle(color: AppColors.subtext, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: sortedPlayers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final pName = sortedPlayers[index];
                final p = globalTotals[pName]!;

                return CustomCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        '#${index + 1}',
                        style: TextStyle(
                          color: index == 0 ? AppColors.gold : AppColors.subtext,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          pName,
                          style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      Text(
                        '🎮 ${p['matches']} J | ⚽ ${p['goals']} G | 👟 ${p['assists']} A | ⭐ ${p['mvps']} MVP',
                        style: const TextStyle(color: AppColors.subtext, fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsChartsTab extends ConsumerWidget {
  const _AnalyticsChartsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalPlayers = ref.watch(playersProvider);
    final tournaments = ref.watch(tournamentsProvider);

    final totals = <String, Map<String, int>>{};
    for (final p in globalPlayers) {
      totals[p] = {'goals': 0, 'assists': 0, 'mvps': 0};
    }

    for (final t in tournaments) {
      for (final act in t.activities) {
        if (act.mvp.isNotEmpty) {
          totals.putIfAbsent(act.mvp, () => {'goals': 0, 'assists': 0, 'mvps': 0});
          totals[act.mvp]!['mvps'] = (totals[act.mvp]!['mvps'] ?? 0) + 1;
        }
        for (final m in act.matches) {
          m.stats.forEach((pName, s) {
            totals.putIfAbsent(pName, () => {'goals': 0, 'assists': 0, 'mvps': 0});
            totals[pName]!['goals'] = (totals[pName]!['goals'] ?? 0) + s.goals;
            totals[pName]!['assists'] = (totals[pName]!['assists'] ?? 0) + s.assists;
          });
        }
      }
    }

    // Top 5 Goals
    final topGoals = totals.entries.toList()
      ..sort((a, b) => b.value['goals']!.compareTo(a.value['goals']!));
    final top5Goals = topGoals.take(5).where((e) => e.value['goals']! > 0).toList();

    // Top 5 Assists
    final topAssists = totals.entries.toList()
      ..sort((a, b) => b.value['assists']!.compareTo(a.value['assists']!));
    final top5Assists = topAssists.take(5).where((e) => e.value['assists']! > 0).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Artilheiros Chart Card
          CustomCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.sports_soccer, color: AppColors.gold, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'TOP 5 ARTILHEIROS DA HISTÓRIA',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (top5Goals.isEmpty)
                  const Text('Nenhum gol registrado ainda.', style: TextStyle(color: AppColors.subtext, fontSize: 12))
                else
                  ...top5Goals.map((entry) {
                    final maxG = top5Goals.first.value['goals']!;
                    final ratio = maxG == 0 ? 0.0 : entry.value['goals']! / maxG;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('${entry.value['goals']!} Gols', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              height: 10,
                              child: LinearProgressIndicator(
                                value: ratio,
                                backgroundColor: AppColors.surfaceHigh,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Top Garçons Chart Card
          CustomCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.sports_score, color: AppColors.secondary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'TOP 5 GARÇONS (ASSISTÊNCIAS)',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (top5Assists.isEmpty)
                  const Text('Nenhuma assistência registrada ainda.', style: TextStyle(color: AppColors.subtext, fontSize: 12))
                else
                  ...top5Assists.map((entry) {
                    final maxA = top5Assists.first.value['assists']!;
                    final ratio = maxA == 0 ? 0.0 : entry.value['assists']! / maxA;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('${entry.value['assists']!} Assists', style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              height: 10,
                              child: LinearProgressIndicator(
                                value: ratio,
                                backgroundColor: AppColors.surfaceHigh,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ByTournamentTab extends ConsumerWidget {
  const _ByTournamentTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournaments = ref.watch(tournamentsProvider);

    if (tournaments.isEmpty) {
      return const Center(
        child: Text('Nenhum torneio cadastrado.', style: TextStyle(color: AppColors.subtext)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tournaments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final t = tournaments[index];
        final isFinished = t.isFinished;

        final totals = <String, Map<String, int>>{};
        for (final p in t.playerNames) {
          totals[p] = {'matches': 0, 'goals': 0, 'assists': 0, 'mvps': 0};
        }

        for (final act in t.activities) {
          if (act.mvp.isNotEmpty && totals.containsKey(act.mvp)) {
            totals[act.mvp]!['mvps'] = (totals[act.mvp]!['mvps'] ?? 0) + 1;
          }
          for (final pName in act.participants) {
            if (totals.containsKey(pName)) {
              totals[pName]!['matches'] = (totals[pName]!['matches'] ?? 0) + 1;
            }
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

        int maxGoals = -1; String? topGoalsPlayer;
        int maxAssists = -1; String? topAssistsPlayer;
        int maxMatches = -1; String? topMatchesPlayer;
        int maxMvps = -1; String? topMvpPlayer;

        if (isFinished) {
          for (final pName in t.playerNames) {
            final p = totals[pName]!;
            if (p['goals']! > maxGoals && p['goals']! > 0) { maxGoals = p['goals']!; topGoalsPlayer = pName; }
            if (p['assists']! > maxAssists && p['assists']! > 0) { maxAssists = p['assists']!; topAssistsPlayer = pName; }
            if (p['matches']! > maxMatches && p['matches']! > 0) { maxMatches = p['matches']!; topMatchesPlayer = pName; }
            if (p['mvps']! > maxMvps && p['mvps']! > 0) { maxMvps = p['mvps']!; topMvpPlayer = pName; }
          }
        }

        return CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🏆 ${t.name}',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (isFinished)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('FINALIZADO', style: TextStyle(color: AppColors.danger, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const Divider(color: AppColors.border, height: 16),
              ...t.playerNames.map((pName) {
                final p = totals[pName] ?? {'matches': 0, 'goals': 0, 'assists': 0, 'mvps': 0};

                RankType? rankType;
                String? rankLabel;

                if (isFinished) {
                  if (pName == topGoalsPlayer) {
                    rankType = RankType.goals;
                    rankLabel = 'Artilheiro (${p['goals']} Gols)';
                  } else if (pName == topAssistsPlayer) {
                    rankType = RankType.assists;
                    rankLabel = 'Garçom (${p['assists']} Assist)';
                  } else if (pName == topMatchesPlayer) {
                    rankType = RankType.matches;
                    rankLabel = 'Maratonista (${p['matches']} Jogos)';
                  } else if (pName == topMvpPlayer) {
                    rankType = RankType.mvp;
                    rankLabel = 'Melhor Jogador (${p['mvps']} MVPs)';
                  }
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            if (rankType != null && rankLabel != null) ...[
                              const SizedBox(height: 2),
                              RankBadge(type: rankType, label: rankLabel),
                            ],
                          ],
                        ),
                      ),
                      Text(
                        '🎮 ${p['matches']} J | ⚽ ${p['goals']} G | 👟 ${p['assists']} A | ⭐ ${p['mvps']} MVP',
                        style: const TextStyle(color: AppColors.subtext, fontSize: 12),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
