import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/tournaments_provider.dart';
import '../widgets/custom_card.dart';

class MatchReportScreen extends ConsumerWidget {
  final int tournamentId;
  final int activityId;
  final int matchId;

  const MatchReportScreen({
    super.key,
    required this.tournamentId,
    required this.activityId,
    required this.matchId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournaments = ref.watch(tournamentsProvider);
    final tList = tournaments.where((t) => t.id == tournamentId).toList();
    if (tList.isEmpty) return const Scaffold(body: Center(child: Text('Torneio não encontrado')));
    
    final tournament = tList.first;
    final actList = tournament.activities.where((a) => a.id == activityId).toList();
    if (actList.isEmpty) return const Scaffold(body: Center(child: Text('Atividade não encontrada')));
    
    final activity = actList.first;
    final mList = activity.matches.where((m) => m.id == matchId).toList();
    if (mList.isEmpty) return const Scaffold(body: Center(child: Text('Partida não encontrada')));
    
    final match = mList.first;

    // Calculate final score
    int goalsA = 0;
    int goalsB = 0;
    
    if (match.teamAPlayers.isNotEmpty || match.teamBPlayers.isNotEmpty) {
      for (final p in match.teamAPlayers) {
        goalsA += match.stats[p]?.goals ?? 0;
      }
      for (final p in match.teamBPlayers) {
        goalsB += match.stats[p]?.goals ?? 0;
      }
    } else {
      match.stats.forEach((key, val) {
        goalsA += val.goals; // Fallback if no specific roster is defined
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Súmula da Partida'),
        backgroundColor: AppColors.cardBackground,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SCOREBOARD HEADER
              CustomCard(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  children: [
                    const Text(
                      'FIM DE JOGO',
                      style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Team A
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primary, width: 2),
                                ),
                                child: const Icon(Icons.shield, color: AppColors.primary, size: 32),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                match.teamAName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),

                        // Score
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHigh,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            '$goalsA x $goalsB',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),

                        // Team B
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.secondary, width: 2),
                                ),
                                child: const Icon(Icons.shield, color: AppColors.secondary, size: 32),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                match.teamBName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      match.matchDate.isNotEmpty ? '${match.matchDate} às ${match.matchTime} • ${match.location}' : match.time,
                      style: const TextStyle(color: AppColors.subtext, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // TIMELINE OF EVENTS
              const Text(
                'Linha do Tempo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              if (match.timelineEvents.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'Nenhum evento registrado nesta partida.',
                      style: TextStyle(color: AppColors.subtext),
                    ),
                  ),
                )
              else
                CustomCard(
                  padding: EdgeInsets.zero,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: match.timelineEvents.length,
                    separatorBuilder: (_, __) => const Divider(color: AppColors.border, height: 1),
                    itemBuilder: (context, index) {
                      final event = match.timelineEvents[index];
                      final type = event['type'] ?? '';
                      final player = event['player'] ?? '';
                      final team = event['team'] ?? '';
                      final time = event['time'] ?? '';

                      IconData icon;
                      Color color;

                      if (type == 'goal') {
                        icon = Icons.sports_soccer;
                        color = AppColors.primary;
                      } else if (type == 'yellow_card') {
                        icon = Icons.style;
                        color = AppColors.gold;
                      } else if (type == 'red_card') {
                        icon = Icons.style;
                        color = AppColors.danger;
                      } else if (type == 'assist') {
                        icon = Icons.handshake;
                        color = AppColors.primary;
                      } else if (type == 'foul') {
                        icon = Icons.sports_kabaddi;
                        color = AppColors.gold;
                      } else {
                        icon = Icons.info;
                        color = AppColors.subtext;
                      }

                      final bool isTeamA = team == match.teamAName;
                      final bool isTeamB = team == match.teamBName;
                      
                      Color baseColor = AppColors.subtext;
                      if (isTeamA) {
                        baseColor = AppColors.primary;
                      } else if (isTeamB) {
                        baseColor = AppColors.secondary;
                      } else if (type == 'red_card') {
                        baseColor = AppColors.danger;
                      } else if (type == 'yellow_card') {
                        baseColor = AppColors.gold;
                      }

                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: baseColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: baseColor.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Icon(icon, color: baseColor, size: 16),
                        ),
                        title: Text(
                          player,
                          style: TextStyle(
                            color: baseColor != AppColors.subtext ? baseColor : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          team,
                          style: const TextStyle(color: AppColors.subtext, fontSize: 12),
                        ),
                        trailing: Text(
                          time,
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
