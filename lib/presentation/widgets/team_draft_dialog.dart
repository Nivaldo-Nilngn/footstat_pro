import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/models/tournament.dart';

class TeamDraftDialog extends StatefulWidget {
  final List<String> availablePlayers;
  final List<Tournament> tournaments;

  const TeamDraftDialog({
    super.key,
    required this.availablePlayers,
    required this.tournaments,
  });

  @override
  State<TeamDraftDialog> createState() => _TeamDraftDialogState();
}

class _TeamDraftDialogState extends State<TeamDraftDialog> {
  int _playersPerTeam = 5;
  bool _balanceByStats = true;
  List<List<String>> _generatedTeams = [];

  @override
  void initState() {
    super.initState();
    _generateTeams();
  }

  Map<String, int> _calculatePlayerScores() {
    final Map<String, int> scores = {};
    for (final player in widget.availablePlayers) {
      scores[player] = 0;
    }

    for (final t in widget.tournaments) {
      for (final act in t.activities) {
        for (final match in act.matches) {
          match.stats.forEach((player, stats) {
            if (scores.containsKey(player)) {
              scores[player] = (scores[player] ?? 0) + (stats.goals * 3) + (stats.assists * 2);
            }
          });
        }
      }
    }
    return scores;
  }

  void _generateTeams() {
    if (widget.availablePlayers.isEmpty) return;

    final players = List<String>.from(widget.availablePlayers);

    if (_balanceByStats) {
      final scores = _calculatePlayerScores();
      // Sort by score descending
      players.sort((a, b) => (scores[b] ?? 0).compareTo(scores[a] ?? 0));
    } else {
      // Random shuffle
      players.shuffle(Random());
    }

    final int numTeams = (players.length / _playersPerTeam).ceil();
    if (numTeams == 0) return;

    final List<List<String>> teams = List.generate(numTeams, (_) => []);

    if (_balanceByStats) {
      // Snake draft (0, 1, 2... 2, 1, 0) to balance teams
      bool forward = true;
      int currentTeam = 0;
      for (final p in players) {
        teams[currentTeam].add(p);
        if (forward) {
          currentTeam++;
          if (currentTeam >= numTeams) {
            currentTeam = numTeams - 1;
            forward = false;
          }
        } else {
          currentTeam--;
          if (currentTeam < 0) {
            currentTeam = 0;
            forward = true;
          }
        }
      }
    } else {
      // Round robin distribution
      for (int i = 0; i < players.length; i++) {
        teams[i % numTeams].add(players[i]);
      }
    }

    setState(() {
      _generatedTeams = teams;
    });
  }

  void _copyTeamsToClipboard() {
    if (_generatedTeams.isEmpty) return;

    final StringBuffer buffer = StringBuffer();
    buffer.writeln('⚽ *SORTEIO DE TIMES - FOOTSTAT PRO*');
    buffer.writeln('────────────────────────');

    for (int i = 0; i < _generatedTeams.length; i++) {
      buffer.writeln('\n👕 *TIME ${i + 1}*');
      for (final player in _generatedTeams[i]) {
        buffer.writeln('  • $player');
      }
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Times copiados! Prontos para colar no WhatsApp. 📲'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.casino, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Sorteio de Times',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.subtext),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Controls Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Jogadores por Time:',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        DropdownButton<int>(
                          value: _playersPerTeam,
                          dropdownColor: AppColors.cardBackground,
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                          items: [3, 4, 5, 6, 7, 8, 11].map((val) {
                            return DropdownMenuItem<int>(
                              value: val,
                              child: Text('$val por time'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _playersPerTeam = val;
                              });
                              _generateTeams();
                            }
                          },
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.border),
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sorteio Equilibrado por Nível',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                'Balanceia os times baseado nos gols e assistências acumulados',
                                style: TextStyle(color: AppColors.subtext, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _balanceByStats,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            setState(() {
                              _balanceByStats = val;
                            });
                            _generateTeams();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Teams Result View
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_generatedTeams.length} TIMES GERADOS (${widget.availablePlayers.length} Jogadores)',
                    style: const TextStyle(
                      color: AppColors.subtext,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  InkWell(
                    onTap: _generateTeams,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: const [
                          Icon(Icons.refresh, color: AppColors.primary, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Re-sortear',
                            style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Column(
                children: List.generate(_generatedTeams.length, (index) {
                  final team = _generatedTeams[index];
                  final colors = [AppColors.primary, AppColors.secondary, AppColors.gold, AppColors.tertiary, AppColors.danger];
                  final color = colors[index % colors.length];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '👕 TIME ${index + 1}',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${team.length} jogadores)',
                              style: const TextStyle(color: AppColors.subtext, fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: team.map((p) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceHigh,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.person, color: AppColors.subtext, size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    p,
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _copyTeamsToClipboard,
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copiar para WhatsApp'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, _generatedTeams),
                      icon: const Icon(Icons.check, color: Colors.black, size: 18),
                      label: const Text('Usar Sorteio'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
