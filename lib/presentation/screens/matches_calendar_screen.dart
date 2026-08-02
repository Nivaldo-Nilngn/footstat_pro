import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/models/match_record.dart';
import '../providers/tournaments_provider.dart';
import '../widgets/custom_card.dart';

class MatchesCalendarScreen extends ConsumerWidget {
  const MatchesCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournaments = ref.watch(tournamentsProvider);

    // Collect all matches across all tournaments & activities
    final List<Map<String, dynamic>> allMatches = [];

    for (final t in tournaments) {
      for (final act in t.activities) {
        for (final m in act.matches) {
          allMatches.add({
            'tournamentName': t.name,
            'tournamentId': t.id,
            'activityName': act.name,
            'activityId': act.id,
            'match': m,
          });
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('📅 Calendário de Jogos & Súmulas'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.calendar_month, color: AppColors.primary, size: 32),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HISTÓRICO DE CONFRONTOS & SÚMULAS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Consulte os placares, datas, tempo de jogo e eventos minuto a minuto de todas as partidas.',
                            style: TextStyle(color: AppColors.subtext, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${allMatches.length} PARTIDAS REGISTRADAS',
                    style: const TextStyle(
                      color: AppColors.subtext,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (allMatches.isEmpty)
                CustomCard(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: const [
                      Icon(Icons.sports_soccer, color: AppColors.subtext, size: 48),
                      SizedBox(height: 12),
                      Text(
                        'NENHUMA PARTIDA REGISTRADA AINDA',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Abra um torneio ou atividade e inicie uma partida Time A vs Time B para registrar placares e súmulas!',
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
                  itemCount: allMatches.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = allMatches[index];
                    final m = item['match'] as MatchRecord;
                    final teamAName = m.teamAName.isNotEmpty ? m.teamAName : 'Time A';
                    final teamBName = m.teamBName.isNotEmpty ? m.teamBName : 'Time B';

                    // Compute Goals per team
                    int goalsA = 0;
                    int goalsB = 0;
                    if (m.teamAPlayers.isNotEmpty || m.teamBPlayers.isNotEmpty) {
                      for (final p in m.teamAPlayers) {
                        goalsA += m.stats[p]?.goals ?? 0;
                      }
                      for (final p in m.teamBPlayers) {
                        goalsB += m.stats[p]?.goals ?? 0;
                      }
                    } else {
                      // Fallback stats count
                      m.stats.forEach((key, val) {
                        goalsA += val.goals;
                      });
                    }

                    return CustomCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${item['tournamentName']} • ${item['activityName']}'.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                m.time,
                                style: const TextStyle(color: AppColors.subtext, fontSize: 10),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Scoreboard Banner
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Text(
                                  teamAName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceHigh,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                                ),
                                child: Text(
                                  '$goalsA  x  $goalsB',
                                  style: const TextStyle(
                                    color: AppColors.gold,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  teamBName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Events summary if available
                          if (m.timelineEvents.isNotEmpty) ...[
                            const Divider(color: AppColors.border, height: 12),
                            Column(
                              children: List.generate(
                                (m.timelineEvents.length > 3 ? 3 : m.timelineEvents.length),
                                (eIdx) {
                                  final ev = m.timelineEvents[eIdx];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      children: [
                                        Text(
                                          '[${ev['time'] ?? '00:00'}]',
                                          style: const TextStyle(color: AppColors.subtext, fontSize: 10, fontFamily: 'monospace'),
                                        ),
                                        const SizedBox(width: 6),
                                        Text('${ev['emoji'] ?? '⚽'}', style: const TextStyle(fontSize: 12)),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${ev['player'] ?? ''} - ${ev['detail'] ?? ''}',
                                          style: const TextStyle(color: Colors.white, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
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
