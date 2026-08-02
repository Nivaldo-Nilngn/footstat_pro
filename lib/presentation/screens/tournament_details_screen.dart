import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/models/match_record.dart';
import '../providers/players_provider.dart';
import '../providers/teams_provider.dart';
import '../providers/tournaments_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/fixture_generator_dialog.dart';
import '../widgets/manual_match_schedule_dialog.dart';
import '../widgets/primary_button.dart';
import 'match_fixture_screen.dart';

class TournamentDetailsScreen extends ConsumerStatefulWidget {
  final int tournamentId;

  const TournamentDetailsScreen({
    super.key,
    required this.tournamentId,
  });

  @override
  ConsumerState<TournamentDetailsScreen> createState() => _TournamentDetailsScreenState();
}

class _TournamentDetailsScreenState extends ConsumerState<TournamentDetailsScreen> {
  void _openRouletteDialog() {
    showDialog(
      context: context,
      builder: (_) => FixtureGeneratorDialog(tournamentId: widget.tournamentId),
    );
  }

  void _openManualScheduleDialog() {
    showDialog(
      context: context,
      builder: (_) => ManualMatchScheduleDialog(tournamentId: widget.tournamentId),
    );
  }

  void _finishTournament(String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Finalizar Torneio', style: TextStyle(color: AppColors.danger)),
        content: Text(
          'Tem certeza que deseja finalizar o torneio "$name"? Não será mais possível adicionar partidas.',
          style: const TextStyle(color: AppColors.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.subtext)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Finalizar Torneio'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(tournamentsProvider.notifier).finishTournament(widget.tournamentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Torneio finalizado com sucesso!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tournaments = ref.watch(tournamentsProvider);
    final teams = ref.watch(teamsProvider);

    final tList = tournaments.where((item) => item.id == widget.tournamentId).toList();
    if (tList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Torneio')),
        body: const Center(child: Text('Torneio não encontrado.')),
      );
    }

    final t = tList.first;
    final isFinished = t.isFinished;

    // Collect all matches across activities
    final List<Map<String, dynamic>> allMatches = [];
    for (final act in t.activities) {
      for (final m in act.matches) {
        allMatches.add({
          'activityId': act.id,
          'activityName': act.name,
          'match': m,
        });
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('🏆 ${t.name}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isFinished) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.dangerBg,
                    border: Border.all(color: AppColors.danger),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock, color: AppColors.danger),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'ESTE TORNEIO FOI FINALIZADO!\nNão é mais possível registrar partidas.',
                          style: TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // CTA Action Buttons: Sorteio Roleta + Agendar Confronto
              if (!isFinished) ...[
                CustomCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🛡️ PAINEL DE GESTÃO DE CONFRONTOS',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Sorteie a tabela de jogos com animação de roleta ou agende confrontos entre os times com data, horário e local de campo!',
                        style: TextStyle(color: AppColors.subtext, fontSize: 11),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _openRouletteDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gold,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.casino, color: Colors.black, size: 18),
                              label: const Text(
                                '🎰 Sorteio (Roleta)',
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _openManualScheduleDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.calendar_month, color: Colors.black, size: 18),
                              label: const Text(
                                '📅 Agendar Jogo',
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Fixtures Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '⚔️ TABELA DE CONFRONTOS DO TORNEIO',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '${allMatches.length} Partidas',
                    style: const TextStyle(color: AppColors.subtext, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (allMatches.isEmpty)
                CustomCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: const [
                      Icon(Icons.sports_soccer, color: AppColors.subtext, size: 44),
                      SizedBox(height: 10),
                      Text('Nenhum confronto agendado.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text(
                        'Clique em "🎰 Sorteio (Roleta)" ou "📅 Agendar Jogo" acima para definir as partidas do torneio!',
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
                    final actId = item['activityId'] as int;
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
                      m.stats.forEach((key, val) {
                        goalsA += val.goals;
                      });
                    }

                    final isMatchFinished = m.status == 'finished' || m.timelineEvents.isNotEmpty || goalsA > 0 || goalsB > 0;

                    return CustomCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date, Time & Location Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: AppColors.subtext, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    m.matchDate.isNotEmpty ? '${m.matchDate} às ${m.matchTime}' : m.time,
                                    style: const TextStyle(color: AppColors.subtext, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              if (m.location.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, color: AppColors.primary, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      m.location,
                                      style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const Divider(color: AppColors.border, height: 20),

                          // Matchup Visualizer (Team A vs Team B)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Team A
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.primary, width: 2),
                                      ),
                                      child: const Icon(Icons.shield, color: AppColors.primary, size: 22),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      teamAName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),

                              // Scoreboard / VS
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceHigh,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isMatchFinished ? AppColors.gold : AppColors.border),
                                ),
                                child: Text(
                                  isMatchFinished ? '$goalsA  x  $goalsB' : 'VS',
                                  style: TextStyle(
                                    color: isMatchFinished ? AppColors.gold : AppColors.subtext,
                                    fontSize: isMatchFinished ? 20 : 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),

                              // Team B
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.secondary, width: 2),
                                      ),
                                      child: const Icon(Icons.shield, color: AppColors.secondary, size: 22),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      teamBName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // CTA Button to Start Match Fixture
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MatchFixtureScreen(
                                    tournamentId: t.id,
                                    activityId: actId,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 42),
                              backgroundColor: isMatchFinished ? AppColors.surfaceHigh : AppColors.primary,
                            ),
                            icon: Icon(
                              isMatchFinished ? Icons.description : Icons.sports_soccer,
                              color: isMatchFinished ? Colors.white : Colors.black,
                              size: 18,
                            ),
                            label: Text(
                              isMatchFinished ? 'Ver Súmula da Partida' : '⚽ Iniciar Partida / Arbitrar',
                              style: TextStyle(
                                color: isMatchFinished ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 24),

              if (!isFinished)
                PrimaryButton(
                  label: '🏁 Finalizar Torneio',
                  color: AppColors.danger,
                  icon: Icons.check_circle_outline,
                  onPressed: () => _finishTournament(t.name),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
