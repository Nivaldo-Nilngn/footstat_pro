import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/players_provider.dart';
import '../providers/tournaments_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/rank_badge.dart';
import 'activity_details_screen.dart';

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
  final TextEditingController _activityNameController = TextEditingController();
  final TextEditingController _activityLiveController = TextEditingController();
  String? _selectedNewPlayer;

  @override
  void dispose() {
    _activityNameController.dispose();
    _activityLiveController.dispose();
    super.dispose();
  }

  void _createActivity() async {
    final text = _activityNameController.text.trim();
    final liveUrl = _activityLiveController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o nome para a atividade!')),
      );
      return;
    }

    await ref.read(tournamentsProvider.notifier).createActivity(widget.tournamentId, text);

    if (liveUrl.isNotEmpty) {
      final tournaments = ref.read(tournamentsProvider);
      final t = tournaments.firstWhere((item) => item.id == widget.tournamentId);
      if (t.activities.isNotEmpty) {
        final lastAct = t.activities.last;
        await ref.read(tournamentsProvider.notifier).setActivityLiveUrl(
              widget.tournamentId,
              lastAct.id,
              liveUrl,
            );
      }
    }

    _activityNameController.clear();
    _activityLiveController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Atividade "$text" criada com sucesso!')),
      );
    }
  }

  void _addPlayerToTournament(List<String> availablePlayers) async {
    if (_selectedNewPlayer == null || _selectedNewPlayer!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um jogador válido!')),
      );
      return;
    }

    await ref.read(tournamentsProvider.notifier).addPlayerToTournament(
          widget.tournamentId,
          _selectedNewPlayer!,
        );

    final added = _selectedNewPlayer;
    setState(() {
      _selectedNewPlayer = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Jogador "$added" adicionado ao torneio!')),
      );
    }
  }

  void _finishTournament(String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Finalizar Torneio', style: TextStyle(color: AppColors.danger)),
        content: Text(
          'Tem certeza que deseja finalizar o torneio "$name"? Não será mais possível adicionar atividades ou alterar partidas.',
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
    final globalPlayers = ref.watch(playersProvider);

    final tList = tournaments.where((item) => item.id == widget.tournamentId).toList();
    if (tList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Torneio')),
        body: const Center(child: Text('Torneio não encontrado.')),
      );
    }

    final t = tList.first;
    final isFinished = t.isFinished;

    final totals = <String, Map<String, int>>{};
    for (final p in t.playerNames) {
      totals[p] = {'matches': 0, 'goals': 0, 'assists': 0, 'mvps': 0};
    }

    for (final act in t.activities) {
      if (act.mvp.isNotEmpty && totals.containsKey(act.mvp)) {
        totals[act.mvp]!['mvps'] = (totals[act.mvp]!['mvps'] ?? 0) + 1;
      }
      for (final pName in act.participants) {
        if (totals.containsKey(pName)) {
          totals[pName]!['matches'] = (totals[pName]!['matches'] ?? 0) + 1;
        }
      }
      for (final m in act.matches) {
        m.stats.forEach((pName, s) {
          if (totals.containsKey(pName)) {
            totals[pName]!['goals'] = (totals[pName]!['goals'] ?? 0) + s.goals;
            totals[pName]!['assists'] = (totals[pName]!['assists'] ?? 0) + s.assists;
          }
        });
      }
    }

    int maxGoals = -1; String? topGoalsPlayer;
    int maxAssists = -1; String? topAssistsPlayer;
    int maxMatches = -1; String? topMatchesPlayer;
    int maxMvps = -1; String? topMvpPlayer;

    if (isFinished) {
      for (final pName in t.playerNames) {
        final p = totals[pName]!;
        if (p['goals']! > maxGoals && p['goals']! > 0) { maxGoals = p['goals']!; topGoalsPlayer = pName; }
        if (p['assists']! > maxAssists && p['assists']! > 0) { maxAssists = p['assists']!; topAssistsPlayer = pName; }
        if (p['matches']! > maxMatches && p['matches']! > 0) { maxMatches = p['matches']!; topMatchesPlayer = pName; }
        if (p['mvps']! > maxMvps && p['mvps']! > 0) { maxMvps = p['mvps']!; topMvpPlayer = pName; }
      }
    }

    final availablePlayers = globalPlayers.where((gp) => !t.playerNames.contains(gp)).toList();

    return Scaffold(
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.lock, color: AppColors.danger),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'ESTE TORNEIO FOI FINALIZADO!\nNão é mais possível registrar partidas ou alterar dados.',
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

              // Card de criação de atividade com Live Link
              if (!isFinished) ...[
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📅 Nova Atividade / Rodada (Evento)',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _activityNameController,
                        decoration: const InputDecoration(
                          hintText: 'Nome (Ex: Rodada #1 - Quinta)',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _activityLiveController,
                        decoration: const InputDecoration(
                          hintText: 'Link da Live (Opcional - YouTube, Twitch, etc.)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: 'Criar Atividade com Transmissão',
                        icon: Icons.add,
                        onPressed: _createActivity,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (availablePlayers.isNotEmpty) ...[
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '➕ Adicionar Jogador ao Torneio',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedNewPlayer,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                dropdownColor: AppColors.cardBackground,
                                hint: const Text('Selecione jogador...'),
                                items: availablePlayers.map((p) {
                                  return DropdownMenuItem(
                                    value: p,
                                    child: Text(p, style: const TextStyle(color: AppColors.text)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedNewPlayer = val;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            PrimaryButton(
                              label: 'Adicionar',
                              isFullWidth: false,
                              onPressed: () => _addPlayerToTournament(availablePlayers),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],

              const Text(
                '📊 Estatísticas do Torneio',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),

              CustomCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: t.playerNames.map((pName) {
                    final p = totals[pName] ?? {'matches': 0, 'goals': 0, 'assists': 0, 'mvps': 0};

                    RankType? rankType;
                    String? rankLabel;

                    if (isFinished) {
                      if (pName == topGoalsPlayer) {
                        rankType = RankType.goals;
                        rankLabel = 'Artilheiro (${p['goals']} Gols)';
                      } else if (pName == topAssistsPlayer) {
                        rankType = RankType.assists;
                        rankLabel = 'Garçom (${p['assists']} Assist)';
                      } else if (pName == topMatchesPlayer) {
                        rankType = RankType.matches;
                        rankLabel = 'Maratonista (${p['matches']} Jogos)';
                      } else if (pName == topMvpPlayer) {
                        rankType = RankType.mvp;
                        rankLabel = 'Melhor Jogador (${p['mvps']} MVPs)';
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pName,
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                if (rankType != null && rankLabel != null) ...[
                                  const SizedBox(height: 2),
                                  RankBadge(type: rankType, label: rankLabel),
                                ],
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              '🎮 ${p['matches']} J | ⚽ ${p['goals']} G | 👟 ${p['assists']} A | ⭐ ${p['mvps']} MVP',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                color: AppColors.subtext,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                '📅 Atividades / Rodadas',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),

              if (t.activities.isEmpty)
                const CustomCard(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Nenhuma atividade cadastrada neste torneio.',
                        style: TextStyle(color: AppColors.subtext),
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: t.activities.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final act = t.activities[index];
                    return CustomCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ActivityDetailsScreen(
                              tournamentId: t.id,
                              activityId: act.id,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '📅 ${act.name}',
                                      style: const TextStyle(
                                        color: AppColors.text,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (act.liveUrl.isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.danger,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          '🔴 LIVE',
                                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                    if (act.isFinished) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.dangerBg,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'FINALIZADA',
                                          style: TextStyle(color: AppColors.danger, fontSize: 9, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${act.participants.length} Presentes | ${act.matches.length} Partidas',
                                  style: const TextStyle(color: AppColors.subtext, fontSize: 12),
                                ),
                                if (act.mvp.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  RankBadge(type: RankType.mvp, label: 'MVP: ${act.mvp}'),
                                ],
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16),
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
