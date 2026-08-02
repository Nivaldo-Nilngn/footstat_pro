import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/models/match_stats.dart';
import '../providers/teams_provider.dart';
import '../providers/tournaments_provider.dart';
import '../providers/live_match_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/primary_button.dart';

class MatchFixtureScreen extends ConsumerStatefulWidget {
  final int tournamentId;
  final int activityId;

  const MatchFixtureScreen({
    super.key,
    required this.tournamentId,
    required this.activityId,
  });

  @override
  ConsumerState<MatchFixtureScreen> createState() => _MatchFixtureScreenState();
}

class _MatchFixtureScreenState extends ConsumerState<MatchFixtureScreen> {
  final TextEditingController _teamAController = TextEditingController(text: 'Time Vermelho');
  final TextEditingController _teamBController = TextEditingController(text: 'Time Azul');

  int _selectedDurationMinutes = 30; // Total = 2 halves (e.g. 30 = 2x15 min)
  bool _isConfigured = false;

  final Map<String, MatchStats> _localPlayerStats = {};
  final Map<String, int> _shirtNumbers = {};
  final Map<String, String> _playerPositions = {};
  final List<String> _teamAPlayers = [];
  final List<String> _teamBPlayers = [];

  @override
  void initState() {
    super.initState();
    _initRosters();
  }

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    super.dispose();
  }

  void _initRosters() {
    final tournaments = ref.read(tournamentsProvider);
    final teams = ref.read(teamsProvider);

    final tList = tournaments.where((t) => t.id == widget.tournamentId).toList();
    if (tList.isEmpty) return;

    final t = tList.first;
    final actList = t.activities.where((a) => a.id == widget.activityId).toList();
    if (actList.isEmpty) return;

    final act = actList.first;

    if (act.matches.isNotEmpty) {
      final lastMatch = act.matches.last;
      if (lastMatch.teamAName.isNotEmpty) _teamAController.text = lastMatch.teamAName;
      if (lastMatch.teamBName.isNotEmpty) _teamBController.text = lastMatch.teamBName;

      if (lastMatch.teamAPlayers.isNotEmpty || lastMatch.teamBPlayers.isNotEmpty) {
        _teamAPlayers.clear();
        _teamAPlayers.addAll(lastMatch.teamAPlayers);
        _teamBPlayers.clear();
        _teamBPlayers.addAll(lastMatch.teamBPlayers);

        final teamAObjList = teams.where((tm) => tm.name.toLowerCase() == _teamAController.text.toLowerCase()).toList();
        final teamBObjList = teams.where((tm) => tm.name.toLowerCase() == _teamBController.text.toLowerCase()).toList();

        for (int i = 0; i < _teamAPlayers.length; i++) {
          final p = _teamAPlayers[i];
          final shirt = teamAObjList.isNotEmpty && teamAObjList.first.shirtNumbers.containsKey(p)
              ? teamAObjList.first.shirtNumbers[p]!
              : (i + 1);
          final pos = teamAObjList.isNotEmpty && teamAObjList.first.playerPositions.containsKey(p)
              ? teamAObjList.first.playerPositions[p]!
              : 'Atacante';

          _shirtNumbers[p] = shirt;
          _playerPositions[p] = pos;
          _localPlayerStats[p] = MatchStats(shirtNumber: shirt);
        }

        for (int i = 0; i < _teamBPlayers.length; i++) {
          final p = _teamBPlayers[i];
          final shirt = teamBObjList.isNotEmpty && teamBObjList.first.shirtNumbers.containsKey(p)
              ? teamBObjList.first.shirtNumbers[p]!
              : (i + 1);
          final pos = teamBObjList.isNotEmpty && teamBObjList.first.playerPositions.containsKey(p)
              ? teamBObjList.first.playerPositions[p]!
              : 'Atacante';

          _shirtNumbers[p] = shirt;
          _playerPositions[p] = pos;
          _localPlayerStats[p] = MatchStats(shirtNumber: shirt);
        }
        return;
      }
    }

    final activePlayers = act.participants.isNotEmpty ? act.participants : t.playerNames;

    for (int i = 0; i < activePlayers.length; i++) {
      final p = activePlayers[i];
      final shirt = (i + 1);
      _shirtNumbers[p] = shirt;
      _playerPositions[p] = 'Atacante';
      _localPlayerStats[p] = MatchStats(shirtNumber: shirt);

      if (i % 2 == 0) {
        _teamAPlayers.add(p);
      } else {
        _teamBPlayers.add(p);
      }
    }
  }

  void _startLiveMatch() {
    ref.read(liveMatchProvider.notifier).initMatch(
          tournamentId: widget.tournamentId,
          activityId: widget.activityId,
          teamAName: _teamAController.text.trim(),
          teamBName: _teamBController.text.trim(),
          durationMinutes: _selectedDurationMinutes,
          teamAPlayers: _teamAPlayers,
          teamBPlayers: _teamBPlayers,
          playerStats: _localPlayerStats,
          shirtNumbers: _shirtNumbers,
          playerPositions: _playerPositions,
        );
    setState(() => _isConfigured = true);
  }

  void _handleBack(LiveMatchState liveState) {
    if (liveState.isLiveActive) {
      ref.read(liveMatchProvider.notifier).minimizeMatch();
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _saveMatchFixture(Map<String, MatchStats> stats) async {
    await ref.read(tournamentsProvider.notifier).saveMatch(
          widget.tournamentId,
          widget.activityId,
          stats,
        );

    ref.read(liveMatchProvider.notifier).closeMatch();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Súmula da partida salva com sucesso! 🏆'),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveState = ref.watch(liveMatchProvider);
    final isLiveCurrent = liveState.isLiveActive &&
        liveState.tournamentId == widget.tournamentId &&
        liveState.activityId == widget.activityId;

    final isMatchConfigured = _isConfigured || isLiveCurrent;

    final displayTeamAName = isLiveCurrent ? liveState.teamAName : _teamAController.text;
    final displayTeamBName = isLiveCurrent ? liveState.teamBName : _teamBController.text;
    final displayTeamAPlayers = isLiveCurrent ? liveState.teamAPlayers : _teamAPlayers;
    final displayTeamBPlayers = isLiveCurrent ? liveState.teamBPlayers : _teamBPlayers;
    final playerStatsMap = isLiveCurrent ? liveState.playerStats : _localPlayerStats;

    final teamAGoals = isLiveCurrent
        ? liveState.teamAGoals
        : displayTeamAPlayers.fold(0, (sum, p) => sum + (playerStatsMap[p]?.goals ?? 0));
    final teamBGoals = isLiveCurrent
        ? liveState.teamBGoals
        : displayTeamBPlayers.fold(0, (sum, p) => sum + (playerStatsMap[p]?.goals ?? 0));

    final isUnlocked = isLiveCurrent && (liveState.secondsElapsed > 0 || liveState.isTimerRunning);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack(liveState);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => _handleBack(liveState),
          ),
          title: Text(isMatchConfigured ? '⚽ Partida em Andamento' : '⚙️ Configurar Partida'),
          actions: [
            if (isLiveCurrent)
              IconButton(
                icon: const Icon(Icons.picture_in_picture_alt, color: AppColors.primary),
                tooltip: 'Minimizar Partida (Modo Flutuante)',
                onPressed: () => _handleBack(liveState),
              ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Setup View (Before Match Start)
                if (!isMatchConfigured) ...[
                  CustomCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CONFIGURAÇÃO DAS EQUIPES & TEMPO DE JOGO',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _teamAController,
                                decoration: const InputDecoration(
                                  labelText: 'Nome do Time A',
                                  prefixIcon: Icon(Icons.shield, color: AppColors.primary),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('VS', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _teamBController,
                                decoration: const InputDecoration(
                                  labelText: 'Nome do Time B',
                                  prefixIcon: Icon(Icons.shield, color: AppColors.secondary),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _selectedDurationMinutes,
                          decoration: const InputDecoration(
                            labelText: 'Duração da Partida',
                            prefixIcon: Icon(Icons.timer, color: AppColors.gold),
                          ),
                          dropdownColor: AppColors.cardBackground,
                          items: {
                              10: '10 min (2x5 min)',
                              16: '16 min (2x8 min)',
                              20: '20 min (2x10 min)',
                              30: '30 min (2x15 min)',
                              40: '40 min (2x20 min)',
                              60: '60 min (2x30 min)',
                              90: '90 min (2x45 min)',
                            }.entries.map((e) {
                              return DropdownMenuItem<int>(
                                value: e.key,
                                child: Text(e.value),
                              );
                            }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedDurationMinutes = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2-Column Team Roster Preview
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Team A Column
                      Expanded(
                        child: CustomCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.shield, color: AppColors.primary, size: 20),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _teamAController.text.toUpperCase(),
                                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: AppColors.border, height: 16),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _teamAPlayers.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, idx) {
                                  final pName = _teamAPlayers[idx];
                                  final shirt = _shirtNumbers[pName] ?? (idx + 1);
                                  final pos = _playerPositions[pName] ?? 'Atacante';

                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceHigh,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.gold.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text('#$shirt', style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(pName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                              Text(pos, style: const TextStyle(color: AppColors.subtext, fontSize: 9)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Team B Column
                      Expanded(
                        child: CustomCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.shield, color: AppColors.secondary, size: 20),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _teamBController.text.toUpperCase(),
                                      style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: AppColors.border, height: 16),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _teamBPlayers.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, idx) {
                                  final pName = _teamBPlayers[idx];
                                  final shirt = _shirtNumbers[pName] ?? (idx + 1);
                                  final pos = _playerPositions[pName] ?? 'Atacante';

                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceHigh,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.gold.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text('#$shirt', style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(pName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                              Text(pos, style: const TextStyle(color: AppColors.subtext, fontSize: 9)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  PrimaryButton(
                    label: '🚀 Confirmar e Ir para o Placar',
                    icon: Icons.sports_soccer,
                    onPressed: _startLiveMatch,
                  ),
                ] else ...[
                  // Live Match Scoreboard Header
                  CustomCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Team A Side
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    displayTeamAName.toUpperCase(),
                                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$teamAGoals',
                                    style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                            ),
                            // Timer Center
                            Column(
                              children: [
                                // Period Label Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  margin: const EdgeInsets.only(bottom: 4),
                                  decoration: BoxDecoration(
                                    color: isLiveCurrent && liveState.currentPeriod == 2
                                        ? Colors.orange.withOpacity(0.2)
                                        : AppColors.primary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isLiveCurrent && liveState.currentPeriod == 2
                                          ? Colors.orange
                                          : AppColors.primary,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    isLiveCurrent ? liveState.periodLabel : '1º TEMPO',
                                    style: TextStyle(
                                      color: isLiveCurrent && liveState.currentPeriod == 2
                                          ? Colors.orange
                                          : AppColors.primary,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                // Time Display
                                Text(
                                  isLiveCurrent ? liveState.formattedTime : '00:00',
                                  style: TextStyle(
                                    color: isLiveCurrent && liveState.currentPeriod == 2
                                        ? Colors.orange
                                        : AppColors.gold,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                // Sub-label: half duration
                                Text(
                                  isLiveCurrent
                                      ? '${liveState.halfDurationMinutes} MIN + ${liveState.halfDurationMinutes} MIN'
                                      : '${_selectedDurationMinutes ~/ 2} MIN + ${_selectedDurationMinutes ~/ 2} MIN',
                                  style: const TextStyle(
                                    color: AppColors.subtext,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // Play / Pause / 2nd Half Button
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: isLiveCurrent && liveState.currentPeriod == 4
                                          ? null // Disabled when match is over
                                          : () {
                                              if (!isLiveCurrent) {
                                                _startLiveMatch();
                                              }
                                              ref.read(liveMatchProvider.notifier).toggleTimer();
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isLiveCurrent && liveState.isTimerRunning
                                            ? Colors.orange
                                            : isLiveCurrent && liveState.currentPeriod == 2
                                                ? Colors.deepOrange
                                                : AppColors.primary,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      ),
                                      icon: Icon(
                                        isLiveCurrent && liveState.isTimerRunning
                                            ? Icons.pause
                                            : isLiveCurrent && liveState.currentPeriod == 2
                                                ? Icons.sports_soccer
                                                : Icons.play_arrow,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                      label: Text(
                                        isLiveCurrent && liveState.isTimerRunning
                                            ? 'PAUSAR'
                                            : isLiveCurrent && liveState.currentPeriod == 2
                                                ? '▶ INICIAR 2º TEMPO'
                                                : '▶ INICIAR PARTIDA',
                                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () {
                                        if (isLiveCurrent) {
                                          ref.read(liveMatchProvider.notifier).resetTimer();
                                        }
                                      },
                                      icon: const Icon(Icons.replay, color: AppColors.subtext, size: 22),
                                      tooltip: 'Reiniciar Partida',
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        if (isLiveCurrent) {
                                          ref.read(liveMatchProvider.notifier).blowWhistleManually();
                                        }
                                      },
                                      icon: const Icon(Icons.volume_up, color: AppColors.gold, size: 22),
                                      tooltip: 'Apito Manual do Árbitro',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Acréscimos
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 4,
                                  children: [1, 2, 3, 5].map((m) {
                                    return InkWell(
                                      onTap: () {
                                        if (isLiveCurrent && !liveState.isHalftime && liveState.currentPeriod != 4) {
                                          ref.read(liveMatchProvider.notifier).addInjuryTime(m);
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.gold.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                                        ),
                                        child: Text(
                                          '+$m\'',
                                          style: const TextStyle(
                                            color: AppColors.gold,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            // Team B Side
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    displayTeamBName.toUpperCase(),
                                    style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w900, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$teamBGoals',
                                    style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Halftime Banner
                        if (isLiveCurrent && liveState.isHalftime) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange, width: 1.5),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.coffee, color: Colors.orange, size: 22),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'INTERVALO ⏸️ — Toque em "▶ INICIAR 2º TEMPO" para continuar!',
                                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 11),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Full Time Banner
                        if (isLiveCurrent && liveState.currentPeriod == 4) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.gold, width: 1.5),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.sports, color: AppColors.gold, size: 22),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'FIM DE JOGO! 📣🏆 Apito Final — 2º Tempo Encerrado!',
                                    style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Locked Action Section (Until Match Timer Starts)
                  Stack(
                    children: [
                      Opacity(
                        opacity: isUnlocked ? 1.0 : 0.35,
                        child: AbsorbPointer(
                          absorbing: !isUnlocked,
                          child: Column(
                            children: [
                              // Rosters in 2 Columns Layout with Actions
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Team A Column
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            displayTeamAName.toUpperCase(),
                                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ...displayTeamAPlayers.map((p) => _buildPlayerMatchTile(
                                              p,
                                              displayTeamAName,
                                              AppColors.primary,
                                              playerStatsMap[p] ?? const MatchStats(),
                                              isLiveCurrent,
                                            )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Team B Column
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondary.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            displayTeamBName.toUpperCase(),
                                            style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ...displayTeamBPlayers.map((p) => _buildPlayerMatchTile(
                                              p,
                                              displayTeamBName,
                                              AppColors.secondary,
                                              playerStatsMap[p] ?? const MatchStats(),
                                              isLiveCurrent,
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Match Timeline / Live Súmula Section
                              CustomCard(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.history, color: AppColors.gold, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          'SÚMULA DA PARTIDA EM TEMPO REAL',
                                          style: TextStyle(
                                            color: AppColors.gold,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (isLiveCurrent && liveState.timelineEvents.isNotEmpty)
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: liveState.timelineEvents.length,
                                        separatorBuilder: (_, __) => const Divider(color: AppColors.border, height: 12),
                                        itemBuilder: (context, index) {
                                          final ev = liveState.timelineEvents[index];
                                          return Row(
                                            children: [
                                              Text(
                                                '[${ev['time']}]',
                                                style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'monospace'),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(ev['emoji']!, style: const TextStyle(fontSize: 14)),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: RichText(
                                                  text: TextSpan(
                                                    style: const TextStyle(fontSize: 12, color: Colors.white),
                                                    children: [
                                                      TextSpan(text: ev['player'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                                      TextSpan(text: ' (${ev['team']}): ', style: const TextStyle(color: AppColors.subtext)),
                                                      TextSpan(text: ev['detail'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      )
                                    else
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                        child: Text(
                                          'Nenhum evento registrado ainda. Marque gols, assistências, faltas ou cartões durante o jogo.',
                                          style: TextStyle(color: AppColors.subtext, fontSize: 11),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (!isUnlocked)
                        Positioned.fill(
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B).withOpacity(0.96),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.gold, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gold.withOpacity(0.3),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.lock, color: AppColors.gold, size: 22),
                                  SizedBox(width: 10),
                                  Text(
                                    'Clique em "▶ INICIAR PARTIDA" para liberar as ações',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  PrimaryButton(
                    label: '🏆 Finalizar e Salvar Súmula',
                    icon: Icons.check_circle,
                    onPressed: () => _saveMatchFixture(playerStatsMap),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerMatchTile(
    String player,
    String teamName,
    Color teamColor,
    MatchStats stats,
    bool isLive,
  ) {
    final shirt = _shirtNumbers[player] ?? 0;
    final pos = _playerPositions[player] ?? 'Atacante';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: teamColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: teamColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#$shirt',
                  style: TextStyle(color: teamColor, fontWeight: FontWeight.w900, fontSize: 11),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(pos, style: const TextStyle(color: AppColors.subtext, fontSize: 9)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _ActionBadge(
                label: '⚽ ${stats.goals}',
                color: AppColors.gold,
                onAdd: () {
                  if (isLive) {
                    ref.read(liveMatchProvider.notifier).updatePlayerStat(player, teamName, 'goals', 1);
                  }
                },
                onSub: () {
                  if (isLive) {
                    ref.read(liveMatchProvider.notifier).updatePlayerStat(player, teamName, 'goals', -1);
                  }
                },
              ),
              _ActionBadge(
                label: '🎯 ${stats.assists}',
                color: AppColors.secondary,
                onAdd: () {
                  if (isLive) {
                    ref.read(liveMatchProvider.notifier).updatePlayerStat(player, teamName, 'assists', 1);
                  }
                },
                onSub: () {
                  if (isLive) {
                    ref.read(liveMatchProvider.notifier).updatePlayerStat(player, teamName, 'assists', -1);
                  }
                },
              ),
              _ActionBadge(
                label: '🛑 ${stats.fouls}',
                color: Colors.orange,
                onAdd: () {
                  if (isLive) {
                    ref.read(liveMatchProvider.notifier).updatePlayerStat(player, teamName, 'fouls', 1);
                  }
                },
                onSub: () {
                  if (isLive) {
                    ref.read(liveMatchProvider.notifier).updatePlayerStat(player, teamName, 'fouls', -1);
                  }
                },
              ),
              _ActionBadge(
                label: '🟨 ${stats.yellowCards}',
                color: AppColors.gold,
                onAdd: () {
                  if (isLive) {
                    ref.read(liveMatchProvider.notifier).updatePlayerStat(player, teamName, 'yellowCards', 1);
                  }
                },
                onSub: () {
                  if (isLive) {
                    ref.read(liveMatchProvider.notifier).updatePlayerStat(player, teamName, 'yellowCards', -1);
                  }
                },
              ),
              _ActionBadge(
                label: '🟥 ${stats.redCards}',
                color: AppColors.danger,
                onAdd: () {
                  if (isLive) {
                    ref.read(liveMatchProvider.notifier).updatePlayerStat(player, teamName, 'redCards', 1);
                  }
                },
                onSub: () {
                  if (isLive) {
                    ref.read(liveMatchProvider.notifier).updatePlayerStat(player, teamName, 'redCards', -1);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBadge extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onAdd;
  final VoidCallback onSub;

  const _ActionBadge({
    required this.label,
    required this.color,
    required this.onAdd,
    required this.onSub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onSub,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
              child: Text('-', style: TextStyle(color: AppColors.subtext, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
          InkWell(
            onTap: onAdd,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
              child: Text('+', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
