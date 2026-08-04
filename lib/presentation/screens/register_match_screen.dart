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
  List<String> _activeMetrics = [];
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
    _activeMetrics = List.from(act.activeMetrics);
    
    final activePlayers = act.participants.isNotEmpty ? act.participants : t.playerNames;

    for (final p in activePlayers) {
      _tempStats[p] = const MatchStats(goalTimestamps: [], customStats: {});
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

  void _updateStat(String pName, String metric, int delta) {
    setState(() {
      final current = _tempStats[pName] ?? const MatchStats();
      final map = Map<String, int>.from(current.customStats);
      final oldVal = map[metric] ?? 0;
      
      // Prevent negative values
      map[metric] = (oldVal + delta).clamp(0, 999);

      // Preserve timestamps for Gols retro-compatibility if the template uses it
      List<int> timestamps = List.from(current.goalTimestamps);
      if (metric == 'Gols') {
        if (delta > 0) {
          timestamps.add(_secondsElapsed);
        } else if (timestamps.isNotEmpty) {
          timestamps.removeLast();
        }
      }

      _tempStats[pName] = current.copyWith(
        customStats: map,
        goalTimestamps: timestamps,
      );
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
          content: Text('Partida salva com sucesso! 🏆'),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildMetricCounter(String pName, String metric, int value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              metric,
              style: const TextStyle(
                color: AppColors.subtext,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.subtext, size: 22),
                onPressed: () => _updateStat(pName, metric, -1),
              ),
              Container(
                width: 36,
                alignment: Alignment.center,
                child: Text(
                  '$value',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 22),
                onPressed: () => _updateStat(pName, metric, 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('🏆 Placar ao Vivo'),
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
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
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
                                width: 36,
                                height: 36,
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
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  pName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Dynamic Metrics Grid
                          if (_activeMetrics.isEmpty)
                            const Center(child: Text('Nenhuma métrica configurada.', style: TextStyle(color: AppColors.subtext)))
                          else
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              childAspectRatio: 2.8,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              children: _activeMetrics.map((metric) {
                                final value = stats.customStats[metric] ?? 0;
                                return _buildMetricCounter(pName, metric, value);
                              }).toList(),
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
