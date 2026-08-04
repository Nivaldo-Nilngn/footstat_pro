import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/models/game_template.dart';
import '../providers/players_provider.dart';
import '../providers/tournaments_provider.dart';
import '../widgets/custom_card.dart';

class HeadToHeadScreen extends ConsumerStatefulWidget {
  const HeadToHeadScreen({super.key});

  @override
  ConsumerState<HeadToHeadScreen> createState() => _HeadToHeadScreenState();
}

class _HeadToHeadScreenState extends ConsumerState<HeadToHeadScreen> {
  String? _playerA;
  String? _playerB;
  GameTemplate _selectedTemplate = GameTemplate.football;

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playersProvider);
    final tournaments = ref.watch(tournamentsProvider);

    if (players.length >= 2) {
      _playerA ??= players[0];
      _playerB ??= players[1];
    }

    final activeMetrics = TemplateMetrics.metrics[_selectedTemplate] ?? [];

    int totalMatchesAgainst = 0;
    int winsA = 0;
    int winsB = 0;
    int draws = 0;

    Map<String, int> statsA = {for (var m in activeMetrics) m: 0};
    Map<String, int> statsB = {for (var m in activeMetrics) m: 0};

    if (_playerA != null && _playerB != null && _playerA != _playerB) {
      for (final t in tournaments) {
        for (final act in t.activities) {
          final actTemplate = GameTemplate.values.firstWhere(
            (e) => e.name == act.gameTemplate,
            orElse: () => GameTemplate.football,
          );
          if (actTemplate != _selectedTemplate) continue;

          for (final m in act.matches) {
            final hasA = m.stats.containsKey(_playerA);
            final hasB = m.stats.containsKey(_playerB);

            // Comparar apenas em partidas em que AMBOS jogaram (confronto direto real)
            if (hasA && hasB) {
              totalMatchesAgainst++;
              final sA = m.stats[_playerA]!;
              final sB = m.stats[_playerB]!;

              for (final metric in activeMetrics) {
                statsA[metric] = (statsA[metric] ?? 0) + (sA.customStats[metric] ?? 0);
                statsB[metric] = (statsB[metric] ?? 0) + (sB.customStats[metric] ?? 0);
              }

              final primaryMetric = activeMetrics.isNotEmpty ? activeMetrics.first : '';
              final scoreA = sA.customStats[primaryMetric] ?? 0;
              final scoreB = sB.customStats[primaryMetric] ?? 0;

              if (scoreA > scoreB) {
                winsA++;
              } else if (scoreB > scoreA) {
                winsB++;
              } else {
                draws++;
              }
            }
          }
        }
      }
    }

    double maxValue = 1.0;
    for (final m in activeMetrics) {
      if (statsA[m]! > maxValue) maxValue = statsA[m]!.toDouble();
      if (statsB[m]! > maxValue) maxValue = statsB[m]!.toDouble();
    }
    maxValue = maxValue == 0 ? 1 : maxValue * 1.1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('🥊 Raio-X X1 (Confronto Direto)'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Player and Template Selection Card
              CustomCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SELECIONE OS COMPETIDORES',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _playerA,
                            decoration: const InputDecoration(labelText: 'Jogador A', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                            items: players.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _playerA = val);
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('VS', style: TextStyle(color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.w900)),
                        ),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _playerB,
                            decoration: const InputDecoration(labelText: 'Jogador B', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                            items: players.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _playerB = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'MODALIDADE',
                      style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(12),
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
                              child: Text(TemplateMetrics.getName(template), style: const TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedTemplate = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (_playerA == null || _playerB == null || _playerA == _playerB)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text('Selecione dois jogadores diferentes para visualizar o confronto direto.', style: TextStyle(color: AppColors.subtext)),
                  ),
                )
              else if (totalMatchesAgainst == 0)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text('Nenhum confronto direto registrado nesta modalidade.', style: TextStyle(color: AppColors.subtext)),
                  ),
                )
              else ...[
                // H2H Scoreboard Card
                CustomCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Player A Side
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(38),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.primary, width: 2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _playerA![0].toUpperCase(),
                                      style: const TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _playerA!,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$winsA Vitórias',
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          
                          // Center Info
                          Column(
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 24)),
                              const SizedBox(height: 8),
                              Text(
                                '$totalMatchesAgainst Jogos',
                                style: const TextStyle(color: AppColors.subtext, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '$draws Empates',
                                style: const TextStyle(color: AppColors.subtext, fontSize: 11),
                              ),
                            ],
                          ),

                          // Player B Side
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withAlpha(38),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.gold, width: 2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _playerB![0].toUpperCase(),
                                      style: const TextStyle(color: AppColors.gold, fontSize: 22, fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _playerB!,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$winsB Vitórias',
                                  style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Radar Chart Section
                if (activeMetrics.isNotEmpty)
                  CustomCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'RADAR DE DESEMPENHO',
                          style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          height: 250,
                          child: RadarChart(
                            RadarChartData(
                              radarShape: RadarShape.polygon,
                              radarBackgroundColor: Colors.transparent,
                              borderData: FlBorderData(show: false),
                              radarBorderData: const BorderSide(color: AppColors.border, width: 1.5),
                              tickBorderData: const BorderSide(color: AppColors.border, width: 1),
                              gridBorderData: const BorderSide(color: AppColors.border, width: 1),
                              tickCount: 4,
                              ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 10),
                              titlePositionMultiplier: 1.25,
                              getTitle: (index, angle) {
                                return RadarChartTitle(
                                  text: activeMetrics[index],
                                  angle: 0,
                                );
                              },
                              dataSets: [
                                RadarDataSet(
                                  fillColor: AppColors.primary.withAlpha(80),
                                  borderColor: AppColors.primary,
                                  entryRadius: 3,
                                  dataEntries: activeMetrics.map((m) => RadarEntry(value: statsA[m]!.toDouble())).toList(),
                                ),
                                RadarDataSet(
                                  fillColor: AppColors.gold.withAlpha(80),
                                  borderColor: AppColors.gold,
                                  entryRadius: 3,
                                  dataEntries: activeMetrics.map((m) => RadarEntry(value: statsB[m]!.toDouble())).toList(),
                                ),
                              ],
                            ),
                            swapAnimationDuration: const Duration(milliseconds: 600),
                            swapAnimationCurve: Curves.easeInOutCubic,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Legend
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(width: 12, height: 12, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(_playerA!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(width: 24),
                            Row(
                              children: [
                                Container(width: 12, height: 12, color: AppColors.gold),
                                const SizedBox(width: 6),
                                Text(_playerB!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Dynamic Comparison Bars
                CustomCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'COMPARAÇÃO DIRETA (Métricas Acumuladas)',
                        style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 16),
                      ...activeMetrics.map((metric) {
                        final valA = statsA[metric] ?? 0;
                        final valB = statsB[metric] ?? 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('$valA', style: TextStyle(color: valA >= valB ? AppColors.primary : Colors.white, fontWeight: FontWeight.bold)),
                                  Text(metric, style: const TextStyle(color: AppColors.subtext, fontSize: 12)),
                                  Text('$valB', style: TextStyle(color: valB >= valA ? AppColors.gold : Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.rotationY(math.pi),
                                      child: LinearProgressIndicator(
                                        value: (valA + valB) == 0 ? 0 : valA / (valA + valB),
                                        backgroundColor: AppColors.border,
                                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                        minHeight: 6,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: (valA + valB) == 0 ? 0 : valB / (valA + valB),
                                      backgroundColor: AppColors.border,
                                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                                      minHeight: 6,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
