import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playersProvider);
    final tournaments = ref.watch(tournamentsProvider);

    if (players.length >= 2) {
      _playerA ??= players[0];
      _playerB ??= players[1];
    }

    int totalMatchesAgainst = 0;
    int winsA = 0;
    int winsB = 0;
    int draws = 0;

    int goalsA = 0;
    int goalsB = 0;
    int assistsA = 0;
    int assistsB = 0;
    int mvpA = 0;
    int mvpB = 0;

    if (_playerA != null && _playerB != null && _playerA != _playerB) {
      for (final t in tournaments) {
        for (final act in t.activities) {
          if (act.mvp == _playerA) mvpA++;
          if (act.mvp == _playerB) mvpB++;

          for (final m in act.matches) {
            final hasA = m.stats.containsKey(_playerA);
            final hasB = m.stats.containsKey(_playerB);

            if (hasA) {
              goalsA += m.stats[_playerA]?.goals ?? 0;
              assistsA += m.stats[_playerA]?.assists ?? 0;
              if (m.stats[_playerA]?.isMvp == true) mvpA++;
            }
            if (hasB) {
              goalsB += m.stats[_playerB]?.goals ?? 0;
              assistsB += m.stats[_playerB]?.assists ?? 0;
              if (m.stats[_playerB]?.isMvp == true) mvpB++;
            }

            // Head-to-head match stats
            if (hasA && hasB) {
              totalMatchesAgainst++;
              final gA = m.stats[_playerA]?.goals ?? 0;
              final gB = m.stats[_playerB]?.goals ?? 0;

              if (gA > gB) {
                winsA++;
              } else if (gB > gA) {
                winsB++;
              } else {
                draws++;
              }
            }
          }
        }
      }
    }

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
              // Player Selection Card
              CustomCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SELECIONE OS COMPETIDORES PARA O CONFRONTO',
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
                            decoration: const InputDecoration(
                              labelText: 'Jogador A',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            items: players.map((p) {
                              return DropdownMenuItem(value: p, child: Text(p));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _playerA = val);
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'VS',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _playerB,
                            decoration: const InputDecoration(
                              labelText: 'Jogador B',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            items: players.map((p) {
                              return DropdownMenuItem(value: p, child: Text(p));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _playerB = val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (_playerA == null || _playerB == null || _playerA == _playerB)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text(
                      'Selecione dois jogadores diferentes para visualizar o confronto direto.',
                      style: TextStyle(color: AppColors.subtext),
                    ),
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
                                    color: AppColors.primary.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.primary, width: 2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _playerA![0].toUpperCase(),
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _playerA!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '$winsA Vitórias',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Center VS Badge
                          Column(
                            children: [
                              Text(
                                '$totalMatchesAgainst',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const Text(
                                'JOGOS DIRETO',
                                style: TextStyle(
                                  color: AppColors.subtext,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$draws Empates',
                                style: const TextStyle(
                                  color: AppColors.subtext,
                                  fontSize: 11,
                                ),
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
                                    color: AppColors.secondary.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.secondary, width: 2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _playerB![0].toUpperCase(),
                                      style: const TextStyle(
                                        color: AppColors.secondary,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _playerB!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '$winsB Vitórias',
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Detailed Comparison Bars
                const Text(
                  'COMPARAÇÃO DETALHADA',
                  style: TextStyle(
                    color: AppColors.subtext,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),

                _ComparisonBar(
                  label: 'Gols Marcados',
                  valueA: goalsA,
                  valueB: goalsB,
                  colorA: AppColors.primary,
                  colorB: AppColors.secondary,
                ),
                const SizedBox(height: 12),

                _ComparisonBar(
                  label: 'Assistências',
                  valueA: assistsA,
                  valueB: assistsB,
                  colorA: AppColors.primary,
                  colorB: AppColors.secondary,
                ),
                const SizedBox(height: 12),

                _ComparisonBar(
                  label: 'Troféus de MVP',
                  valueA: mvpA,
                  valueB: mvpB,
                  colorA: AppColors.gold,
                  colorB: AppColors.gold,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ComparisonBar extends StatelessWidget {
  final String label;
  final int valueA;
  final int valueB;
  final Color colorA;
  final Color colorB;

  const _ComparisonBar({
    required this.label,
    required this.valueA,
    required this.valueB,
    required this.colorA,
    required this.colorB,
  });

  @override
  Widget build(BuildContext context) {
    final total = (valueA + valueB) == 0 ? 1 : (valueA + valueB);
    final ratioA = valueA / total;

    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$valueA',
                style: TextStyle(color: colorA, fontWeight: FontWeight.w900, fontSize: 18),
              ),
              Text(
                label.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Text(
                '$valueB',
                style: TextStyle(color: colorB, fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(
                    flex: (ratioA * 100).toInt(),
                    child: Container(color: colorA),
                  ),
                  Expanded(
                    flex: ((1 - ratioA) * 100).toInt(),
                    child: Container(color: colorB),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
