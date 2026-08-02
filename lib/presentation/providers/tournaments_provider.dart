import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/storage_repository.dart';
import '../../domain/models/tournament.dart';
import '../../domain/models/activity.dart';
import '../../domain/models/match_record.dart';
import '../../domain/models/match_stats.dart';
import 'players_provider.dart';

class TournamentsNotifier extends StateNotifier<List<Tournament>> {
  final StorageRepository _repository;

  TournamentsNotifier(this._repository) : super([]) {
    _loadTournaments();
  }

  Future<void> _loadTournaments() async {
    state = await _repository.loadTournaments();
  }

  Future<void> _save() async {
    await _repository.saveTournaments(state);
  }

  Future<void> createTournament(String name, List<String> playerNames) async {
    final newTournament = Tournament(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name.trim(),
      status: 'active',
      playerNames: List.from(playerNames),
      activities: [],
    );

    state = [...state, newTournament];
    await _save();
  }

  Future<void> renameTournament(int id, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    state = state.map((t) {
      if (t.id == id) {
        return t.copyWith(name: trimmed);
      }
      return t;
    }).toList();

    await _save();
  }

  Future<void> deleteTournament(int id) async {
    state = state.where((t) => t.id != id).toList();
    await _save();
  }

  Future<void> addPlayerToTournament(int tournamentId, String playerName) async {
    state = state.map((t) {
      if (t.id == tournamentId && !t.playerNames.contains(playerName)) {
        final updatedPlayers = [...t.playerNames, playerName];
        return t.copyWith(playerNames: updatedPlayers);
      }
      return t;
    }).toList();

    await _save();
  }

  Future<void> finishTournament(int tournamentId) async {
    state = state.map((t) {
      if (t.id == tournamentId) {
        return t.copyWith(status: 'finished');
      }
      return t;
    }).toList();

    await _save();
  }

  Future<void> createActivity(int tournamentId, String activityName) async {
    state = state.map((t) {
      if (t.id == tournamentId && !t.isFinished) {
        final newActivity = Activity(
          id: DateTime.now().millisecondsSinceEpoch,
          name: activityName.trim(),
          status: 'active',
          mvp: '',
          liveUrl: '',
          participants: List.from(t.playerNames),
          matches: [],
        );
        return t.copyWith(activities: [...t.activities, newActivity]);
      }
      return t;
    }).toList();

    await _save();
  }

  Future<void> toggleParticipant(int tournamentId, int activityId, String playerName, bool isPresent) async {
    state = state.map((t) {
      if (t.id == tournamentId && !t.isFinished) {
        final updatedActivities = t.activities.map((act) {
          if (act.id == activityId && !act.isFinished) {
            final list = List<String>.from(act.participants);
            if (isPresent) {
              if (!list.contains(playerName)) list.add(playerName);
            } else {
              list.remove(playerName);
            }
            return act.copyWith(participants: list);
          }
          return act;
        }).toList();

        return t.copyWith(activities: updatedActivities);
      }
      return t;
    }).toList();

    await _save();
  }

  Future<void> setActivityMvp(int tournamentId, int activityId, String playerName) async {
    state = state.map((t) {
      if (t.id == tournamentId && !t.isFinished) {
        final updatedActivities = t.activities.map((act) {
          if (act.id == activityId && !act.isFinished) {
            return act.copyWith(mvp: playerName);
          }
          return act;
        }).toList();

        return t.copyWith(activities: updatedActivities);
      }
      return t;
    }).toList();

    await _save();
  }

  Future<void> setActivityLiveUrl(int tournamentId, int activityId, String liveUrl) async {
    state = state.map((t) {
      if (t.id == tournamentId && !t.isFinished) {
        final updatedActivities = t.activities.map((act) {
          if (act.id == activityId && !act.isFinished) {
            return act.copyWith(liveUrl: liveUrl.trim());
          }
          return act;
        }).toList();

        return t.copyWith(activities: updatedActivities);
      }
      return t;
    }).toList();

    await _save();
  }

  Future<void> finishActivity(int tournamentId, int activityId) async {
    state = state.map((t) {
      if (t.id == tournamentId) {
        final updatedActivities = t.activities.map((act) {
          if (act.id == activityId) {
            return act.copyWith(status: 'finished');
          }
          return act;
        }).toList();

        return t.copyWith(activities: updatedActivities);
      }
      return t;
    }).toList();

    await _save();
  }

  Future<void> saveMatch(int tournamentId, int activityId, Map<String, MatchStats> tempStats) async {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final timeStr = '$day/$month/${now.year} $hour:$minute';

    state = state.map((t) {
      if (t.id == tournamentId && !t.isFinished) {
        final updatedActivities = t.activities.map((act) {
          if (act.id == activityId && !act.isFinished) {
            final newMatch = MatchRecord(
              id: DateTime.now().millisecondsSinceEpoch,
              time: timeStr,
              stats: Map.from(tempStats),
            );
            return act.copyWith(matches: [...act.matches, newMatch]);
          }
          return act;
        }).toList();

        return t.copyWith(activities: updatedActivities);
      }
      return t;
    }).toList();

    await _save();
  }

  Future<void> deleteMatch(int tournamentId, int activityId, int matchIndex) async {
    state = state.map((t) {
      if (t.id == tournamentId && !t.isFinished) {
        final updatedActivities = t.activities.map((act) {
          if (act.id == activityId && !act.isFinished) {
            if (matchIndex >= 0 && matchIndex < act.matches.length) {
              final newMatches = List<MatchRecord>.from(act.matches)..removeAt(matchIndex);
              return act.copyWith(matches: newMatches);
            }
          }
          return act;
        }).toList();

        return t.copyWith(activities: updatedActivities);
      }
      return t;
    }).toList();

    await _save();
  }

  Future<void> importTournament(Tournament imported) async {
    state = [...state, imported];
    await _save();
  }

  Future<void> cascadeRenamePlayer(String oldName, String newName) async {
    state = state.map((t) {
      final updatedPlayers = t.playerNames.map((p) => p == oldName ? newName : p).toList();

      final updatedActivities = t.activities.map((act) {
        final newMvp = act.mvp == oldName ? newName : act.mvp;
        final newParticipants = act.participants.map((p) => p == oldName ? newName : p).toList();

        final newMatches = act.matches.map((m) {
          final newStats = <String, MatchStats>{};
          m.stats.forEach((key, value) {
            final k = key == oldName ? newName : key;
            newStats[k] = value;
          });
          return m.copyWith(stats: newStats);
        }).toList();

        return act.copyWith(
          mvp: newMvp,
          participants: newParticipants,
          matches: newMatches,
        );
      }).toList();

      return t.copyWith(
        playerNames: updatedPlayers,
        activities: updatedActivities,
      );
    }).toList();

    await _save();
  }
}

final tournamentsProvider = StateNotifierProvider<TournamentsNotifier, List<Tournament>>((ref) {
  final repo = ref.watch(storageRepositoryProvider);
  return TournamentsNotifier(repo);
});
