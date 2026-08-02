import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/live_match_provider.dart';
import '../screens/match_fixture_screen.dart';

class FloatingLiveMatchPlayer extends ConsumerWidget {
  const FloatingLiveMatchPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveState = ref.watch(liveMatchProvider);

    if (!liveState.isLiveActive || !liveState.isMinimized) {
      return const SizedBox.shrink();
    }

    final isMobile = MediaQuery.of(context).size.width < 700;

    return Positioned(
      bottom: isMobile ? 70 : 20,
      right: isMobile ? 12 : 24,
      left: isMobile ? 12 : null,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: isMobile ? null : 380,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.96),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              ref.read(liveMatchProvider.notifier).expandMatch();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MatchFixtureScreen(
                    tournamentId: liveState.tournamentId,
                    activityId: liveState.activityId,
                  ),
                ),
              );
            },
            child: Row(
              children: [
                // Live Indicator / Pulse
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: liveState.isTimerRunning ? AppColors.danger.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: liveState.isTimerRunning ? AppColors.danger : Colors.orange),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: liveState.isTimerRunning ? AppColors.danger : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        liveState.isTimerRunning ? '🔴 ${liveState.periodLabel}' : '⏸️ ${liveState.periodLabel}',
                        style: TextStyle(
                          color: liveState.isTimerRunning ? AppColors.danger : Colors.orange,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Score & Team Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${liveState.teamAName}  ${liveState.teamAGoals} x ${liveState.teamBGoals}  ${liveState.teamBName}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.timer, color: AppColors.gold, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            liveState.currentInjuryTime > 0
                                ? '${liveState.formattedTime} (+${liveState.currentInjuryTime}\')'
                                : liveState.formattedTime,
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Controls
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Play / Pause Toggle
                    IconButton(
                      iconSize: 22,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      icon: Icon(
                        liveState.isTimerRunning ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        color: AppColors.primary,
                      ),
                      onPressed: () {
                        ref.read(liveMatchProvider.notifier).toggleTimer();
                      },
                    ),

                    // Expand / Restore Button
                    IconButton(
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      icon: const Icon(Icons.open_in_full, color: Colors.white),
                      onPressed: () {
                        ref.read(liveMatchProvider.notifier).expandMatch();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MatchFixtureScreen(
                              tournamentId: liveState.tournamentId,
                              activityId: liveState.activityId,
                            ),
                          ),
                        );
                      },
                    ),

                    // Close / End Match Button
                    IconButton(
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      icon: const Icon(Icons.close, color: AppColors.subtext),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppColors.cardBackground,
                            title: const Text('Encerrar Partida ao Vivo?', style: TextStyle(color: Colors.white)),
                            content: const Text(
                              'Você deseja fechar o acompanhamento ao vivo da partida?',
                              style: TextStyle(color: AppColors.subtext),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancelar', style: TextStyle(color: AppColors.subtext)),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                                onPressed: () {
                                  ref.read(liveMatchProvider.notifier).closeMatch();
                                  Navigator.pop(ctx);
                                },
                                child: const Text('Encerrar Partida'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
