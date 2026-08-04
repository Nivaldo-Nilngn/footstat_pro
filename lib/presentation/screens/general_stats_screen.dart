import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/models/game_template.dart';
import '../providers/players_provider.dart';
import '../providers/tournaments_provider.dart';
import '../widgets/custom_card.dart';

class GeneralStatsScreen extends ConsumerStatefulWidget {
  const GeneralStatsScreen({super.key});

  @override
  ConsumerState<GeneralStatsScreen> createState() => _GeneralStatsScreenState();
}

class _GeneralStatsScreenState extends ConsumerState<GeneralStatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  GameTemplate _selectedTemplate = GameTemplate.football;

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
        title: const Text('📊 Analytics Avançado'),
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
            Tab(text: 'Gráficos (Top 5)'),
            Tab(text: 'Por Torneio'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.cardBackground,
            child: Row(
              children: [
                const Icon(Icons.filter_list, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Modalidade:',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<GameTemplate>(
                        value: _selectedTemplate,
                        isExpanded: true,
                        dropdownColor: AppColors.surfaceHigh,
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.subtext),
                        items: GameTemplate.values.map((template) {
                          return DropdownMenuItem(
                            value: template,
                            child: Text(
                              TemplateMetrics.getName(template),
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedTemplate = val);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _AllTimeHistoryTab(template: _selectedTemplate),
                _AnalyticsChartsTab(template: _selectedTemplate),
                _ByTournamentTab(template: _selectedTemplate),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllTimeHistoryTab extends ConsumerWidget {
  final GameTemplate template;
  const _AllTimeHistoryTab({required this.template});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalPlayers = ref.watch(playersProvider);
    final tournaments = ref.watch(tournamentsProvider);
    final activeMetrics = TemplateMetrics.metrics[template] ?? [];

    final globalTotals = <String, Map<String, int>>{};
    for (final p in globalPlayers) {
      globalTotals[p] = {'matches': 0, 'mvps': 0, for (var m in activeMetrics) m: 0};
    }

    for (final t in tournaments) {
      if (t.gameTemplate != template.name) continue;

      for (final act in t.activities) {
        if (act.mvp.isNotEmpty) {
          globalTotals.putIfAbsent(act.mvp, () => {'matches': 0, 'mvps': 0, for (var m in activeMetrics) m: 0});
          globalTotals[act.mvp]!['mvps'] = (globalTotals[act.mvp]!['mvps'] ?? 0) + 1;
        }

        for (final pName in act.participants) {
          globalTotals.putIfAbsent(pName, () => {'matches': 0, 'mvps': 0, for (var m in activeMetrics) m: 0});
          globalTotals[pName]!['matches'] = (globalTotals[pName]!['matches'] ?? 0) + 1;
        }

        for (final m in act.matches) {
          m.stats.forEach((pName, s) {
            globalTotals.putIfAbsent(pName, () => {'matches': 0, 'mvps': 0, for (var m in activeMetrics) m: 0});
            for (var metric in activeMetrics) {
              globalTotals[pName]![metric] = (globalTotals[pName]![metric] ?? 0) + (s.customStats[metric] ?? 0);
            }
          });
        }
      }
    }

    final sortMetric = activeMetrics.isNotEmpty ? activeMetrics.first : 'matches';
    final sortedPlayers = globalTotals.keys.toList()
      ..sort((a, b) => (globalTotals[b]![sortMetric] ?? 0).compareTo(globalTotals[a]![sortMetric] ?? 0));

    if (sortedPlayers.isEmpty || activeMetrics.isEmpty) {
      return const Center(child: Text('Nenhum dado cadastrado para esta modalidade.', style: TextStyle(color: AppColors.subtext)));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Ranking Acumulado',
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
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
                        style: TextStyle(color: index == 0 ? AppColors.gold : AppColors.subtext, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              children: [
                                Text('🎮 ${p['matches']} J', style: const TextStyle(color: AppColors.subtext, fontSize: 11)),
                                Text('⭐ ${p['mvps']} MVP', style: const TextStyle(color: AppColors.subtext, fontSize: 11)),
                                ...activeMetrics.map((m) {
                                  return Text('• ${p[m]} $m', style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600));
                                }).toList(),
                              ],
                            ),
                          ],
                        ),
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
  final GameTemplate template;
  const _AnalyticsChartsTab({required this.template});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalPlayers = ref.watch(playersProvider);
    final tournaments = ref.watch(tournamentsProvider);
    final activeMetrics = TemplateMetrics.metrics[template] ?? [];

    final totals = <String, Map<String, int>>{};
    for (final p in globalPlayers) {
      totals[p] = {for (var m in activeMetrics) m: 0};
    }

    for (final t in tournaments) {
      if (t.gameTemplate != template.name) continue;
      for (final act in t.activities) {
        for (final m in act.matches) {
          m.stats.forEach((pName, s) {
            totals.putIfAbsent(pName, () => {for (var m in activeMetrics) m: 0});
            for (var metric in activeMetrics) {
              totals[pName]![metric] = (totals[pName]![metric] ?? 0) + (s.customStats[metric] ?? 0);
            }
          });
        }
      }
    }

    if (activeMetrics.isEmpty) {
      return const Center(child: Text('Nenhuma métrica disponível.', style: TextStyle(color: AppColors.subtext)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: activeMetrics.length,
      itemBuilder: (context, index) {
        final metric = activeMetrics[index];
        final sorted = totals.entries.toList()
          ..sort((a, b) => b.value[metric]!.compareTo(a.value[metric]!));
        final top5 = sorted.take(5).where((e) => e.value[metric]! > 0).toList();

        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: CustomCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bar_chart, color: AppColors.gold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'TOP 5 - ${metric.toUpperCase()}',
                      style: const TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (top5.isEmpty)
                  const Text('Nenhum dado registrado para esta métrica.', style: TextStyle(color: AppColors.subtext, fontSize: 12))
                else
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: top5.first.value[metric]!.toDouble() * 1.2,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${top5[group.x.toInt()].key}\n',
                                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: '${(rod.toY - 1).round()} $metric',
                                    style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final text = top5[value.toInt()].key;
                                final initials = text.length > 4 ? text.substring(0, 4) : text;
                                return SideTitleWidget(
                                  meta: meta,
                                  space: 4.0,
                                  child: Text(initials, style: const TextStyle(color: AppColors.subtext, fontSize: 10, fontWeight: FontWeight.bold)),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        barGroups: top5.asMap().entries.map((e) {
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value.value[metric]!.toDouble() + 1, // +1 for visual effect if value is 0 but shouldn't happen due to filter
                                color: AppColors.primary,
                                width: 22,
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: top5.first.value[metric]!.toDouble() * 1.2,
                                  color: AppColors.surfaceHigh,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ByTournamentTab extends ConsumerWidget {
  final GameTemplate template;
  const _ByTournamentTab({required this.template});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournaments = ref.watch(tournamentsProvider).where((t) => t.gameTemplate == template.name).toList();

    if (tournaments.isEmpty) {
      return const Center(child: Text('Nenhum torneio cadastrado nesta modalidade.', style: TextStyle(color: AppColors.subtext)));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tournaments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final t = tournaments[index];
        final activeMetrics = TemplateMetrics.metrics[template] ?? [];

        final tTotals = <String, Map<String, int>>{};
        for (final p in t.playerNames) {
          tTotals[p] = {'matches': 0, 'mvps': 0, for (var m in activeMetrics) m: 0};
        }

        for (final act in t.activities) {
          if (act.mvp.isNotEmpty) {
            tTotals.putIfAbsent(act.mvp, () => {'matches': 0, 'mvps': 0, for (var m in activeMetrics) m: 0});
            tTotals[act.mvp]!['mvps'] = (tTotals[act.mvp]!['mvps'] ?? 0) + 1;
          }
          for (final pName in act.participants) {
            tTotals.putIfAbsent(pName, () => {'matches': 0, 'mvps': 0, for (var m in activeMetrics) m: 0});
            tTotals[pName]!['matches'] = (tTotals[pName]!['matches'] ?? 0) + 1;
          }
          for (final m in act.matches) {
            m.stats.forEach((pName, s) {
              tTotals.putIfAbsent(pName, () => {'matches': 0, 'mvps': 0, for (var m in activeMetrics) m: 0});
              for (var metric in activeMetrics) {
                tTotals[pName]![metric] = (tTotals[pName]![metric] ?? 0) + (s.customStats[metric] ?? 0);
              }
            });
          }
        }

        final sortMetric = activeMetrics.isNotEmpty ? activeMetrics.first : 'matches';
        final sortedPlayers = tTotals.keys.toList()
          ..sort((a, b) => (tTotals[b]![sortMetric] ?? 0).compareTo(tTotals[a]![sortMetric] ?? 0));

        return CustomCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.name,
                style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
              ),
              const SizedBox(height: 12),
              if (sortedPlayers.isEmpty)
                const Text('Nenhum dado cadastrado.', style: TextStyle(color: AppColors.subtext))
              else
                ...sortedPlayers.take(10).map((pName) {
                  final p = tTotals[pName]!;
                  final rank = sortedPlayers.indexOf(pName) + 1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          child: Text(
                            '$rankº',
                            style: TextStyle(
                              color: rank == 1 ? AppColors.gold : AppColors.subtext,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            pName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            if (activeMetrics.isNotEmpty)
                              Text(
                                '${p[activeMetrics.first]} ${activeMetrics.first}',
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            const SizedBox(width: 8),
                            Text('⭐ ${p['mvps']}', style: const TextStyle(color: AppColors.subtext, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
            ],
          ),
        );
      },
    );
  }
}
