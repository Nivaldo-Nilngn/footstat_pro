import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/storage_repository.dart';
import '../../domain/models/team.dart';
import 'players_provider.dart';

class TeamsNotifier extends StateNotifier<List<Team>> {
  final StorageRepository _repository;

  TeamsNotifier(this._repository) : super([]) {
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    state = await _repository.loadTeams();
  }

  Future<void> _save() async {
    await _repository.saveTeams(state);
  }

  Future<void> createTeam(
    String name, {
    String primaryColorHex = '#3B82F6',
    String secondaryColorHex = '#171F33',
    String logoIcon = 'shield',
    String logoBase64 = '',
    String stadium = '',
    String city = '',
    String foundedYear = '',
    String description = '',
  }) async {
    final newTeam = Team(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name.trim(),
      primaryColorHex: primaryColorHex,
      secondaryColorHex: secondaryColorHex,
      logoIcon: logoIcon,
      logoBase64: logoBase64,
      stadium: stadium,
      city: city,
      foundedYear: foundedYear,
      description: description,
      players: [],
    );

    state = [...state, newTeam];
    await _save();
  }

  Future<void> deleteTeam(int id) async {
    state = state.where((t) => t.id != id).toList();
    await _save();
  }

  Future<void> addPlayerToTeam(int teamId, String playerName, {int shirtNumber = 10, String position = 'Atacante'}) async {
    state = state.map((t) {
      if (t.id == teamId && !t.players.contains(playerName)) {
        final newShirts = Map<String, int>.from(t.shirtNumbers)..[playerName] = shirtNumber;
        final newPositions = Map<String, String>.from(t.playerPositions)..[playerName] = position;
        return t.copyWith(
          players: [...t.players, playerName],
          shirtNumbers: newShirts,
          playerPositions: newPositions,
        );
      }
      return t;
    }).toList();

    await _save();
  }

  Future<void> updatePlayerMember(int teamId, String playerName, int shirtNumber, String position) async {
    state = state.map((t) {
      if (t.id == teamId && t.players.contains(playerName)) {
        final newShirts = Map<String, int>.from(t.shirtNumbers)..[playerName] = shirtNumber;
        final newPositions = Map<String, String>.from(t.playerPositions)..[playerName] = position;
        return t.copyWith(
          shirtNumbers: newShirts,
          playerPositions: newPositions,
        );
      }
      return t;
    }).toList();

    await _save();
  }

  Future<void> removePlayerFromTeam(int teamId, String playerName) async {
    state = state.map((t) {
      if (t.id == teamId) {
        final updatedPlayers = t.players.where((p) => p != playerName).toList();
        final newShirts = Map<String, int>.from(t.shirtNumbers)..remove(playerName);
        final newPositions = Map<String, String>.from(t.playerPositions)..remove(playerName);

        final newCaptain = t.captain == playerName ? '' : t.captain;
        final newGk = t.goalkeeper == playerName ? '' : t.goalkeeper;
        final newPen = t.penaltyTaker == playerName ? '' : t.penaltyTaker;
        final newFk = t.freeKickTaker == playerName ? '' : t.freeKickTaker;

        return t.copyWith(
          players: updatedPlayers,
          shirtNumbers: newShirts,
          playerPositions: newPositions,
          captain: newCaptain,
          goalkeeper: newGk,
          penaltyTaker: newPen,
          freeKickTaker: newFk,
        );
      }
      return t;
    }).toList();

    await _save();
  }

  Future<void> setTeamRole(int teamId, String roleType, String playerName) async {
    state = state.map((t) {
      if (t.id == teamId) {
        if (roleType == 'captain') {
          return t.copyWith(captain: playerName);
        } else if (roleType == 'goalkeeper') {
          return t.copyWith(goalkeeper: playerName);
        } else if (roleType == 'penaltyTaker') {
          return t.copyWith(penaltyTaker: playerName);
        } else if (roleType == 'freeKickTaker') {
          return t.copyWith(freeKickTaker: playerName);
        }
      }
      return t;
    }).toList();

    await _save();
  }
}

final teamsProvider = StateNotifierProvider<TeamsNotifier, List<Team>>((ref) {
  final repo = ref.watch(storageRepositoryProvider);
  return TeamsNotifier(repo);
});
