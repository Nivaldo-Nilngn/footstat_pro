import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/models/match_stats.dart';
import '../providers/tournaments_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/primary_button.dart';

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

  @override
  void initState() {
    super.initState();
    _initTempStats();
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
      _tempStats[p] = const MatchStats(goals: 0, assists: 0);
    }
  }

  void _updateStat(String pName, String field, int delta) {
    setState(() {
      final current = _tempStats[pName] ?? const MatchStats();
      if (field == 'goals') {
        final newGoals = (current.goals + delta).clamp(0, 99);
        _tempStats[pName] = current.copyWith(goals: newGoals);
      } else if (field == 'assists') {
        final newAssists = (current.assists + delta).clamp(0, 99);
        _tempStats[pName] = current.copyWith(assists: newAssists);
      }
    });
  }

  void _saveMatch() async {
    await ref.read(tournamentsProvider.notifier).saveMatch(
          widget.tournamentId,
          widget.activityId,
          _tempStats,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Partida registrada com sucesso!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚽ Registrar Partida'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: _tempStats.keys.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final pName = _tempStats.keys.elementAt(index);
                    final stats = _tempStats[pName]!;

                    return CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                pName,
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
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
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        '⚽ Gols',
                                        style: TextStyle(
                                          color: AppColors.subtext,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          _CounterButton(
                                            label: '-',
                                            onPressed: () => _updateStat(pName, 'goals', -1),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                            child: Text(
                                              '${stats.goals}',
                                              style: const TextStyle(
                                                color: AppColors.text,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          _CounterButton(
                                            label: '+',
                                            onPressed: () => _updateStat(pName, 'goals', 1),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Assistencias counter
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        '👟 Assistências',
                                        style: TextStyle(
                                          color: AppColors.subtext,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          _CounterButton(
                                            label: '-',
                                            onPressed: () => _updateStat(pName, 'assists', -1),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                            child: Text(
                                              '${stats.assists}',
                                              style: const TextStyle(
                                                color: AppColors.text,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          _CounterButton(
                                            label: '+',
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
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: '💾 Salvar Partida',
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

class _CounterButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _CounterButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
