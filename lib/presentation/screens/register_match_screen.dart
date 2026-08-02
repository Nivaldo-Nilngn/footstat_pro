import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/models/match_stats.dart';
import '../providers/tournaments_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/team_draft_dialog.dart';

class RegisterMatchScreen extends ConsumerStatefulWidget {
  final int tournamentId;
  final int activityId;

  const RegisterMatchScreen({
    super.key,
    required this.tournamentId,
    required this.activityId,
  });

  @override
  ConsumerState<RegisterMatchScreen> createState() => _RegisterMatchScreenState();
}

class _RegisterMatchScreenState extends ConsumerState<RegisterMatchScreen> {
  final Map<String, MatchStats> _tempStats = {};
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _initTempStats();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initTempStats() {
    final tournaments = ref.read(tournamentsProvider);
    final tList = tournaments.where((t) => t.id == widget.tournamentId).toList();
    if (tList.isEmpty) return;

    final t = tList.first;
    final actList = t.activities.where((a) => a.id == widget.activityId).toList();
    if (actList.isEmpty) return;

    final act = actList.first;
    final activePlayers = act.participants.isNotEmpty ? act.participants : t.playerNames;

    for (final p in activePlayers) {
      _tempStats[p] = const MatchStats(goals: 0, assists: 0, goalTimestamps: []);
    }
  }

  void _toggleTimer() {
    if (_isTimerRunning) {
      _timer?.cancel();
      setState(() => _isTimerRunning = false);
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() => _secondsElapsed++);
      });
      setState(() => _isTimerRunning = true);
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _secondsElapsed = 0;
      _isTimerRunning = false;
    });
  }

  String _formatTimer(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _updateStat(String pName, String field, int delta) {
    setState(() {
      final current = _tempStats[pName] ?? const MatchStats();
      if (field == 'goals') {
        final newGoals = (current.goals + delta).clamp(0, 99);
        final List<int> timestamps = List.from(current.goalTimestamps);

        if (delta > 0) {
          timestamps.add(_secondsElapsed);
        } else if (timestamps.isNotEmpty) {
          timestamps.removeLast();
        }

        _tempStats[pName] = current.copyWith(
          goals: newGoals,
          goalTimestamps: timestamps,
        );
      } else if (field == 'assists') {
        final newAssists = (current.assists + delta).clamp(0, 99);
        _tempStats[pName] = current.copyWith(assists: newAssists);
      } else if (field == 'yellowCards') {
        final newY = (current.yellowCards + delta).clamp(0, 5);
        _tempStats[pName] = current.copyWith(yellowCards: newY);
      } else if (field == 'redCards') {
        final newR = (current.redCards + delta).clamp(0, 2);
        _tempStats[pName] = current.copyWith(redCards: newR);
      }
    });
  }

  void _openDraftDialog() {
    final players = _tempStats.keys.toList();
    final tournaments = ref.read(tournamentsProvider);
    showDialog(
      context: context,
      builder: (_) => TeamDraftDialog(
        availablePlayers: players,
        tournaments: tournaments,
      ),
    );
  }

  void _saveMatch() async {
    await ref.read(tournamentsProvider.notifier).saveMatch(
          widget.tournamentId,
          widget.activityId,
          _tempStats,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Partida salva com sucesso! ⚽'),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('⚽ Placar ao Vivo & Cronômetro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.casino, color: AppColors.primary),
            tooltip: 'Sorteio de Times',
            onPressed: _openDraftDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Live Timer Banner
              CustomCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _isTimerRunning ? AppColors.danger : AppColors.subtext,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isTimerRunning ? 'EM ANDAMENTO' : 'CRONÔMETRO PAUSADO',
                              style: TextStyle(
                                color: _isTimerRunning ? AppColors.danger : AppColors.subtext,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimer(_secondsElapsed),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _toggleTimer,
                          icon: Icon(
                            _isTimerRunning ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            color: AppColors.primary,
                            size: 40,
                          ),
                          tooltip: _isTimerRunning ? 'Pausar' : 'Iniciar',
                        ),
                        IconButton(
                          onPressed: _resetTimer,
                          icon: const Icon(Icons.replay, color: AppColors.subtext, size: 24),
                          tooltip: 'Zerar Cronômetro',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView.separated(
                  itemCount: _tempStats.keys.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final pName = _tempStats.keys.elementAt(index);
                    final stats = _tempStats[pName]!;
                    final initial = pName.isNotEmpty ? pName[0].toUpperCase() : '?';

                    return CustomCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                ),
                                child: Center(
                                  child: Text(
                                    initial,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  pName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // Gols counter
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceHigh,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.sports_soccer, color: AppColors.gold, size: 16),
                                          SizedBox(width: 4),
                                          Text('Gols', style: TextStyle(color: AppColors.subtext, fontSize: 11, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.subtext, size: 20),
                                            onPressed: () => _updateStat(pName, 'goals', -1),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: Text(
                                              '${stats.goals}',
                                              style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w900, fontSize: 16),
                                            ),
                                          ),
                                          IconButton(
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.add_circle, color: AppColors.gold, size: 20),
                                            onPressed: () => _updateStat(pName, 'goals', 1),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Assists counter
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceHigh,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.sports_score, color: AppColors.secondary, size: 16),
                                          SizedBox(width: 4),
                                          Text('Assist.', style: TextStyle(color: AppColors.subtext, fontSize: 11, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.subtext, size: 20),
                                            onPressed: () => _updateStat(pName, 'assists', -1),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: Text(
                                              '${stats.assists}',
                                              style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w900, fontSize: 16),
                                            ),
                                          ),
                                          IconButton(
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.add_circle, color: AppColors.secondary, size: 20),
                                            onPressed: () => _updateStat(pName, 'assists', 1),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Cards row (Yellow & Red)
                          Row(
                            children: [
                              // Yellow card
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceHigh,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('🟨 Amarelo', style: TextStyle(color: AppColors.subtext, fontSize: 11, fontWeight: FontWeight.bold)),
                                      Row(
                                        children: [
                                          IconButton(
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.subtext, size: 18),
                                            onPressed: () => _updateStat(pName, 'yellowCards', -1),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 6),
                                            child: Text(
                                              '${stats.yellowCards}',
                                              style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                          ),
                                          IconButton(
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.add_circle, color: AppColors.gold, size: 18),
                                            onPressed: () => _updateStat(pName, 'yellowCards', 1),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Red card
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceHigh,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('🟥 Vermelho', style: TextStyle(color: AppColors.subtext, fontSize: 11, fontWeight: FontWeight.bold)),
                                      Row(
                                        children: [
                                          IconButton(
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.subtext, size: 18),
                                            onPressed: () => _updateStat(pName, 'redCards', -1),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 6),
                                            child: Text(
                                              '${stats.redCards}',
                                              style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                          ),
                                          IconButton(
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.add_circle, color: AppColors.danger, size: 18),
                                            onPressed: () => _updateStat(pName, 'redCards', 1),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Salvar Partida na Atividade',
                icon: Icons.save,
                onPressed: _saveMatch,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
