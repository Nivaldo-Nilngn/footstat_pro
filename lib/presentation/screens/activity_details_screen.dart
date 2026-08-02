import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../providers/tournaments_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/rank_badge.dart';
import 'register_match_screen.dart';

class ActivityDetailsScreen extends ConsumerStatefulWidget {
  final int tournamentId;
  final int activityId;

  const ActivityDetailsScreen({
    super.key,
    required this.tournamentId,
    required this.activityId,
  });

  @override
  ConsumerState<ActivityDetailsScreen> createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends ConsumerState<ActivityDetailsScreen> {
  final TextEditingController _liveUrlController = TextEditingController();

  @override
  void dispose() {
    _liveUrlController.dispose();
    super.dispose();
  }

  void _saveLiveUrl() async {
    final text = _liveUrlController.text.trim();
    await ref.read(tournamentsProvider.notifier).setActivityLiveUrl(
          widget.tournamentId,
          widget.activityId,
          text,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link da Live / Transmissão salvo com sucesso!')),
      );
    }
  }

  void _finishActivity(String actName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Finalizar Atividade', style: TextStyle(color: AppColors.danger)),
        content: Text(
          'Deseja finalizar a atividade "$actName"? Não será mais possível alterar participantes, partidas ou MVP.',
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
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(tournamentsProvider.notifier).finishActivity(widget.tournamentId, widget.activityId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atividade finalizada com sucesso!')),
        );
      }
    }
  }

  void _deleteMatch(int matchIndex) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Excluir Partida', style: TextStyle(color: AppColors.danger)),
        content: const Text('Deseja excluir esta partida? As estatísticas serão recalculadas.', style: TextStyle(color: AppColors.text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.subtext)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(tournamentsProvider.notifier).deleteMatch(widget.tournamentId, widget.activityId, matchIndex);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Partida excluída.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tournaments = ref.watch(tournamentsProvider);
    final tList = tournaments.where((t) => t.id == widget.tournamentId).toList();

    if (tList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Atividade')),
        body: const Center(child: Text('Torneio não encontrado.')),
      );
    }

    final t = tList.first;
    final actList = t.activities.where((a) => a.id == widget.activityId).toList();
    if (actList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Atividade')),
        body: const Center(child: Text('Atividade não encontrada.')),
      );
    }

    final act = actList.first;
    final isActFinished = act.isFinished || t.isFinished;

    if (_liveUrlController.text.isEmpty && act.liveUrl.isNotEmpty) {
      _liveUrlController.text = act.liveUrl;
    }

    // Calcular estatísticas da atividade
    final actTotals = <String, Map<String, int>>{};
    for (final p in t.playerNames) {
      actTotals[p] = {
        'matches': act.participants.contains(p) ? 1 : 0,
        'goals': 0,
        'assists': 0,
      };
    }

    for (final match in act.matches) {
      match.stats.forEach((pName, s) {
        if (actTotals.containsKey(pName)) {
          actTotals[pName]!['goals'] = (actTotals[pName]!['goals'] ?? 0) + s.goals;
          actTotals[pName]!['assists'] = (actTotals[pName]!['assists'] ?? 0) + s.assists;
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('📅 ${act.name}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isActFinished) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.dangerBg,
                    border: Border.all(color: AppColors.danger),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ATIVIDADE FINALIZADA!\nAs alterações foram bloqueadas.',
                    style: TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Card da Live / Transmissão
              CustomCard(
                backgroundColor: AppColors.cardSecondary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.videocam, color: AppColors.danger),
                        SizedBox(width: 8),
                        Text(
                          '🔴 Transmissão Ao Vivo / Gravação',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Cole o link da live ou gravação (YouTube, Twitch, Drive) para guardar como recordação.',
                      style: TextStyle(color: AppColors.subtext, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _liveUrlController,
                            enabled: !isActFinished,
                            style: const TextStyle(fontSize: 13),
                            decoration: const InputDecoration(
                              hintText: 'https://youtube.com/...',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        PrimaryButton(
                          label: 'Salvar',
                          color: AppColors.danger,
                          isFullWidth: false,
                          isSmall: true,
                          onPressed: isActFinished ? null : _saveLiveUrl,
                        ),
                      ],
                    ),
                    if (act.liveUrl.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: '🔴 Assistir Transmissão Ao Vivo / Gravação',
                        color: AppColors.danger,
                        icon: Icons.open_in_new,
                        onPressed: () {
                          Share.share('Assista a gravação/live da rodada ${act.name}: ${act.liveUrl}');
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Botão Registrar Partida
              if (!isActFinished) ...[
                PrimaryButton(
                  label: '⚽ Registrar Nova Partida',
                  icon: Icons.sports_soccer,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RegisterMatchScreen(
                          tournamentId: widget.tournamentId,
                          activityId: widget.activityId,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              // MVP Selection
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⭐ Escolha do MVP da Atividade',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: act.mvp.isEmpty ? null : act.mvp,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      dropdownColor: AppColors.cardBackground,
                      hint: const Text('Selecione o MVP...'),
                      items: t.playerNames.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text('⭐ $p', style: const TextStyle(color: AppColors.text)),
                        );
                      }).toList(),
                      onChanged: isActFinished
                          ? null
                          : (val) {
                              if (val != null) {
                                ref.read(tournamentsProvider.notifier).setActivityMvp(
                                      widget.tournamentId,
                                      widget.activityId,
                                      val,
                                    );
                              }
                            },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Lista de Presença
              const Text(
                '👥 Lista de Presença (Participantes)',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),

              CustomCard(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: t.playerNames.map((pName) {
                    final isChecked = act.participants.contains(pName);
                    return CheckboxListTile(
                      enabled: !isActFinished,
                      activeColor: AppColors.primary,
                      title: Text(
                        pName,
                        style: TextStyle(
                          color: isChecked ? AppColors.text : AppColors.subtext,
                          fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      value: isChecked,
                      onChanged: isActFinished
                          ? null
                          : (val) {
                              ref.read(tournamentsProvider.notifier).toggleParticipant(
                                    widget.tournamentId,
                                    widget.activityId,
                                    pName,
                                    val ?? false,
                                  );
                            },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Resumo de Desempenho na Atividade
              const Text(
                '📊 Desempenho da Atividade',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),

              CustomCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: t.playerNames.map((pName) {
                    final p = actTotals[pName] ?? {'matches': 0, 'goals': 0, 'assists': 0};
                    final isMvp = act.mvp == pName;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  pName,
                                  style: TextStyle(
                                    color: p['matches']! > 0 ? AppColors.text : AppColors.subtext,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (isMvp) ...[
                                  const SizedBox(width: 8),
                                  const RankBadge(type: RankType.mvp, label: 'MVP'),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            '🎮 ${p['matches']} J | ⚽ ${p['goals']} G | 👟 ${p['assists']} A',
                            style: const TextStyle(
                              color: AppColors.subtext,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Partidas da Atividade
              const Text(
                '📜 Partidas Registradas',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),

              if (act.matches.isEmpty)
                const CustomCard(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Nenhuma partida registrada nesta atividade ainda.',
                        style: TextStyle(color: AppColors.subtext),
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: act.matches.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final m = act.matches[idx];
                    return CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Partida #${idx + 1} (${m.time})',
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (!isActFinished)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                                  onPressed: () => _deleteMatch(idx),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ...m.stats.entries.where((e) => e.value.goals > 0 || e.value.assists > 0).map((e) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Text(
                                '• ${e.key}: ${e.value.goals > 0 ? '${e.value.goals} Gols ' : ''}${e.value.assists > 0 ? '${e.value.assists} Assist' : ''}',
                                style: const TextStyle(color: AppColors.subtext, fontSize: 13),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 24),

              if (!isActFinished)
                PrimaryButton(
                  label: '🏁 Finalizar Atividade',
                  color: AppColors.danger,
                  icon: Icons.check,
                  onPressed: () => _finishActivity(act.name),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
