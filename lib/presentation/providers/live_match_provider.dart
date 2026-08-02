import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/sound_effects.dart';
import '../../domain/models/match_stats.dart';

class LiveMatchState {
  final bool isLiveActive;
  final bool isMinimized;
  final int tournamentId;
  final int activityId;
  final String teamAName;
  final String teamBName;
  final int selectedDurationMinutes; // Total match duration (e.g. 30 = 15min per half)
  final int secondsElapsed;
  final bool isTimerRunning;
  final int currentPeriod; // 1 = 1º Tempo, 2 = Intervalo, 3 = 2º Tempo, 4 = Fim de Jogo
  final int addedInjuryTimeMinutes1stHalf;
  final int addedInjuryTimeMinutes2ndHalf;
  final List<String> teamAPlayers;
  final List<String> teamBPlayers;
  final Map<String, MatchStats> playerStats;
  final Map<String, int> shirtNumbers;
  final Map<String, String> playerPositions;
  final List<Map<String, String>> timelineEvents;

  const LiveMatchState({
    this.isLiveActive = false,
    this.isMinimized = false,
    this.tournamentId = 0,
    this.activityId = 0,
    this.teamAName = 'Time A',
    this.teamBName = 'Time B',
    this.selectedDurationMinutes = 30,
    this.secondsElapsed = 0,
    this.isTimerRunning = false,
    this.currentPeriod = 1,
    this.addedInjuryTimeMinutes1stHalf = 0,
    this.addedInjuryTimeMinutes2ndHalf = 0,
    this.teamAPlayers = const [],
    this.teamBPlayers = const [],
    this.playerStats = const {},
    this.shirtNumbers = const {},
    this.playerPositions = const {},
    this.timelineEvents = const [],
  });

  int get halfDurationMinutes => selectedDurationMinutes ~/ 2;
  int get halfDurationSeconds => halfDurationMinutes * 60;

  int get target1stHalfSeconds => halfDurationSeconds + (addedInjuryTimeMinutes1stHalf * 60);
  int get targetFullMatchSeconds => (halfDurationSeconds * 2) + (addedInjuryTimeMinutes1stHalf * 60) + (addedInjuryTimeMinutes2ndHalf * 60);

  int get currentInjuryTime => currentPeriod <= 2 ? addedInjuryTimeMinutes1stHalf : addedInjuryTimeMinutes2ndHalf;

  bool get isTimeEnded => currentPeriod == 4 || (currentPeriod == 3 && secondsElapsed >= targetFullMatchSeconds);
  bool get isHalftime => currentPeriod == 2;

  String get periodLabel {
    switch (currentPeriod) {
      case 1:
        return '1º TEMPO';
      case 2:
        return 'INTERVALO';
      case 3:
        return '2º TEMPO';
      case 4:
        return 'FIM DE JOGO';
      default:
        return '1º TEMPO';
    }
  }

  int get teamAGoals => teamAPlayers.fold(0, (sum, p) => sum + (playerStats[p]?.goals ?? 0));
  int get teamBGoals => teamBPlayers.fold(0, (sum, p) => sum + (playerStats[p]?.goals ?? 0));

  String get formattedTime {
    final m = (secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final s = (secondsElapsed % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  LiveMatchState copyWith({
    bool? isLiveActive,
    bool? isMinimized,
    int? tournamentId,
    int? activityId,
    String? teamAName,
    String? teamBName,
    int? selectedDurationMinutes,
    int? secondsElapsed,
    bool? isTimerRunning,
    int? currentPeriod,
    int? addedInjuryTimeMinutes1stHalf,
    int? addedInjuryTimeMinutes2ndHalf,
    List<String>? teamAPlayers,
    List<String>? teamBPlayers,
    Map<String, MatchStats>? playerStats,
    Map<String, int>? shirtNumbers,
    Map<String, String>? playerPositions,
    List<Map<String, String>>? timelineEvents,
  }) {
    return LiveMatchState(
      isLiveActive: isLiveActive ?? this.isLiveActive,
      isMinimized: isMinimized ?? this.isMinimized,
      tournamentId: tournamentId ?? this.tournamentId,
      activityId: activityId ?? this.activityId,
      teamAName: teamAName ?? this.teamAName,
      teamBName: teamBName ?? this.teamBName,
      selectedDurationMinutes: selectedDurationMinutes ?? this.selectedDurationMinutes,
      secondsElapsed: secondsElapsed ?? this.secondsElapsed,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      currentPeriod: currentPeriod ?? this.currentPeriod,
      addedInjuryTimeMinutes1stHalf: addedInjuryTimeMinutes1stHalf ?? this.addedInjuryTimeMinutes1stHalf,
      addedInjuryTimeMinutes2ndHalf: addedInjuryTimeMinutes2ndHalf ?? this.addedInjuryTimeMinutes2ndHalf,
      teamAPlayers: teamAPlayers ?? this.teamAPlayers,
      teamBPlayers: teamBPlayers ?? this.teamBPlayers,
      playerStats: playerStats ?? this.playerStats,
      shirtNumbers: shirtNumbers ?? this.shirtNumbers,
      playerPositions: playerPositions ?? this.playerPositions,
      timelineEvents: timelineEvents ?? this.timelineEvents,
    );
  }
}

class LiveMatchNotifier extends StateNotifier<LiveMatchState> {
  Timer? _timer;

  LiveMatchNotifier() : super(const LiveMatchState());

  void initMatch({
    required int tournamentId,
    required int activityId,
    required String teamAName,
    required String teamBName,
    required int durationMinutes,
    required List<String> teamAPlayers,
    required List<String> teamBPlayers,
    required Map<String, MatchStats> playerStats,
    required Map<String, int> shirtNumbers,
    required Map<String, String> playerPositions,
  }) {
    state = LiveMatchState(
      isLiveActive: true,
      isMinimized: false,
      tournamentId: tournamentId,
      activityId: activityId,
      teamAName: teamAName,
      teamBName: teamBName,
      selectedDurationMinutes: durationMinutes,
      currentPeriod: 1,
      secondsElapsed: 0,
      teamAPlayers: List.from(teamAPlayers),
      teamBPlayers: List.from(teamBPlayers),
      playerStats: Map.from(playerStats),
      shirtNumbers: Map.from(shirtNumbers),
      playerPositions: Map.from(playerPositions),
    );
  }

  void toggleTimer() {
    if (state.isTimerRunning) {
      _timer?.cancel();
      state = state.copyWith(isTimerRunning: false);
    } else {
      if (state.currentPeriod == 2) {
        // Resume to 2nd Half
        startSecondHalf();
        return;
      }

      if (state.currentPeriod == 4) {
        return; // Match already finished
      }

      state = state.copyWith(isTimerRunning: true);
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        final newSeconds = state.secondsElapsed + 1;

        if (state.currentPeriod == 1) {
          final target1st = state.target1stHalfSeconds;
          if (newSeconds == target1st) {
            // End of 1st Half -> Halftime!
            SoundEffects.playWhistle();
            _timer?.cancel();

            final newEvents = [
              {
                'time': state.formattedTime,
                'emoji': '⏸️',
                'player': 'Arbitragem',
                'team': 'Jogo',
                'detail': 'FIM DO 1º TEMPO / INTERVALO DA PARTIDA',
              },
              ...state.timelineEvents,
            ];

            state = state.copyWith(
              secondsElapsed: newSeconds,
              isTimerRunning: false,
              currentPeriod: 2, // Move to Halftime
              timelineEvents: newEvents,
            );
          } else {
            if (target1st - newSeconds <= 5 && target1st - newSeconds > 0) {
              SoundEffects.playWarningTick();
            }
            state = state.copyWith(secondsElapsed: newSeconds);
          }
        } else if (state.currentPeriod == 3) {
          final targetFull = state.targetFullMatchSeconds;
          if (newSeconds == targetFull) {
            // End of 2nd Half -> Match Finished!
            SoundEffects.playWhistle();
            _timer?.cancel();

            final newEvents = [
              {
                'time': state.formattedTime,
                'emoji': '📣',
                'player': 'Arbitragem',
                'team': 'Jogo',
                'detail': 'FIM DE JOGO! Apito Final do Árbitro 🏆',
              },
              ...state.timelineEvents,
            ];

            state = state.copyWith(
              secondsElapsed: newSeconds,
              isTimerRunning: false,
              currentPeriod: 4, // Full Time
              timelineEvents: newEvents,
            );
          } else {
            if (targetFull - newSeconds <= 5 && targetFull - newSeconds > 0) {
              SoundEffects.playWarningTick();
            }
            state = state.copyWith(secondsElapsed: newSeconds);
          }
        }
      });
    }
  }

  void startSecondHalf() {
    _timer?.cancel();
    final startSeconds = state.target1stHalfSeconds;
    final timeStr = state.formattedTime;

    final newEvents = [
      {
        'time': timeStr,
        'emoji': '▶️',
        'player': 'Arbitragem',
        'team': 'Jogo',
        'detail': 'INÍCIO DO 2º TEMPO DA PARTIDA',
      },
      ...state.timelineEvents,
    ];

    state = state.copyWith(
      currentPeriod: 3, // 2º Tempo
      secondsElapsed: startSeconds,
      isTimerRunning: true,
      timelineEvents: newEvents,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final newSeconds = state.secondsElapsed + 1;
      final targetFull = state.targetFullMatchSeconds;

      if (newSeconds == targetFull) {
        SoundEffects.playWhistle();
        _timer?.cancel();

        final endEvents = [
          {
            'time': state.formattedTime,
            'emoji': '📣',
            'player': 'Arbitragem',
            'team': 'Jogo',
            'detail': 'FIM DE JOGO! Apito Final do Árbitro 🏆',
          },
          ...state.timelineEvents,
        ];

        state = state.copyWith(
          secondsElapsed: newSeconds,
          isTimerRunning: false,
          currentPeriod: 4,
          timelineEvents: endEvents,
        );
      } else {
        if (targetFull - newSeconds <= 5 && targetFull - newSeconds > 0) {
          SoundEffects.playWarningTick();
        }
        state = state.copyWith(secondsElapsed: newSeconds);
      }
    });
  }

  void blowWhistleManually() {
    SoundEffects.playWhistle();
    final timeStr = state.formattedTime;
    final newEvents = [
      {
        'time': timeStr,
        'emoji': '🎷',
        'player': 'Árbitro',
        'team': 'Jogo',
        'detail': 'Apito Manual do Árbitro (${state.periodLabel})',
      },
      ...state.timelineEvents,
    ];
    state = state.copyWith(timelineEvents: newEvents);
  }

  void resetTimer() {
    _timer?.cancel();
    state = state.copyWith(secondsElapsed: 0, isTimerRunning: false, currentPeriod: 1);
  }

  void addInjuryTime(int minutes) {
    final timeStr = state.formattedTime;
    int newInj1 = state.addedInjuryTimeMinutes1stHalf;
    int newInj2 = state.addedInjuryTimeMinutes2ndHalf;

    if (state.currentPeriod <= 2) {
      newInj1 += minutes;
    } else {
      newInj2 += minutes;
    }

    final newEvents = [
      {
        'time': timeStr,
        'emoji': '⏱️',
        'player': 'Arbitragem',
        'team': 'Jogo',
        'detail': '+$minutes min de Acréscimo adicionados ao ${state.periodLabel}!',
      },
      ...state.timelineEvents,
    ];

    state = state.copyWith(
      addedInjuryTimeMinutes1stHalf: newInj1,
      addedInjuryTimeMinutes2ndHalf: newInj2,
      timelineEvents: newEvents,
    );
  }

  void updatePlayerStat(String player, String teamName, String statType, int delta) {
    final currentStats = state.playerStats[player] ?? const MatchStats();
    MatchStats updatedStats = currentStats;

    if (statType == 'goals') {
      final newVal = (currentStats.goals + delta).clamp(0, 99);
      updatedStats = currentStats.copyWith(goals: newVal);
    } else if (statType == 'assists') {
      final newVal = (currentStats.assists + delta).clamp(0, 99);
      updatedStats = currentStats.copyWith(assists: newVal);
    } else if (statType == 'fouls') {
      final newVal = (currentStats.fouls + delta).clamp(0, 99);
      updatedStats = currentStats.copyWith(fouls: newVal);
    } else if (statType == 'yellowCards') {
      final newVal = (currentStats.yellowCards + delta).clamp(0, 2);
      updatedStats = currentStats.copyWith(yellowCards: newVal);
    } else if (statType == 'redCards') {
      final newVal = (currentStats.redCards + delta).clamp(0, 1);
      updatedStats = currentStats.copyWith(redCards: newVal);
    }

    final newPlayerStats = Map<String, MatchStats>.from(state.playerStats)..[player] = updatedStats;
    List<Map<String, String>> newEvents = List.from(state.timelineEvents);

    if (delta > 0) {
      final timeStr = state.formattedTime;
      String emoji = '⚡';
      String detail = statType;

      if (statType == 'goals') {
        emoji = '⚽';
        detail = 'GOLAZO! (${state.periodLabel})';
      } else if (statType == 'assists') {
        emoji = '🎯';
        detail = 'Assistência (${state.periodLabel})';
      } else if (statType == 'fouls') {
        emoji = '🛑';
        detail = 'Falta Cometida (${state.periodLabel})';
      } else if (statType == 'yellowCards') {
        emoji = '🟨';
        detail = 'Cartão Amarelo (${state.periodLabel})';
      } else if (statType == 'redCards') {
        emoji = '🟥';
        detail = 'Cartão Vermelho / Expulsão (${state.periodLabel})';
      }

      newEvents.insert(0, {
        'time': timeStr,
        'emoji': emoji,
        'player': player,
        'team': teamName,
        'detail': detail,
      });
    }

    state = state.copyWith(
      playerStats: newPlayerStats,
      timelineEvents: newEvents,
    );
  }

  void minimizeMatch() {
    if (state.isLiveActive) {
      state = state.copyWith(isMinimized: true);
    }
  }

  void expandMatch() {
    state = state.copyWith(isMinimized: false);
  }

  void closeMatch() {
    _timer?.cancel();
    state = const LiveMatchState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final liveMatchProvider = StateNotifierProvider<LiveMatchNotifier, LiveMatchState>((ref) {
  return LiveMatchNotifier();
});
