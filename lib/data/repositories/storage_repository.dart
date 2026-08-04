import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/tournament.dart';
import '../../domain/models/team.dart';

class StorageRepository {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get userId => _auth.currentUser?.uid;

  Future<List<String>> loadGlobalPlayers() async {
    if (userId == null) return [];
    try {
      final snapshot = await _db.ref('users/$userId/data/globalPlayers').get();
      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> map = snapshot.value as Map<dynamic, dynamic>;
        final List<dynamic> list = map['players'] ?? [];
        return list.map((e) => e.toString()).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> saveGlobalPlayers(List<String> players) async {
    if (userId == null) return;
    await _db.ref('users/$userId/data/globalPlayers').set({
      'players': players,
    });
  }

  Future<List<Tournament>> loadTournaments() async {
    if (userId == null) return [];
    try {
      final snapshot = await _db.ref('users/$userId/tournaments').get();
      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> map = snapshot.value as Map<dynamic, dynamic>;
        final List<Tournament> tournaments = [];
        
        map.forEach((key, value) {
          final tMap = Map<String, dynamic>.from(value as Map);
          tournaments.add(Tournament.fromJson(tMap));
        });
        
        return tournaments;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTournaments(List<Tournament> tournaments) async {
    if (userId == null) return;
    final Map<String, dynamic> updates = {};
    for (var t in tournaments) {
      final data = t.toJson();
      data['creatorId'] = userId;
      updates[t.id.toString()] = data;
    }
    await _db.ref('users/$userId/tournaments').set(updates);
  }

  Future<List<Team>> loadTeams() async {
    if (userId == null) return _getDefaultTeams();
    try {
      final snapshot = await _db.ref('users/$userId/data/teams').get();
      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> map = snapshot.value as Map<dynamic, dynamic>;
        final List<dynamic> list = map['teams'] ?? [];
        return list.map((item) {
          final itemMap = item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item as Map);
          return Team.fromJson(itemMap);
        }).toList();
      }
      return _getDefaultTeams();
    } catch (_) {
      return _getDefaultTeams();
    }
  }

  Future<void> saveTeams(List<Team> teams) async {
    if (userId == null) return;
    final jsonList = teams.map((t) => t.toJson()).toList();
    await _db.ref('users/$userId/data/teams').set({
      'teams': jsonList,
    });
  }

  List<Team> _getDefaultTeams() {
    return [
      const Team(
        id: 101,
        name: 'Tigres do Society',
        primaryColorHex: '#FF4D4D',
        secondaryColorHex: '#171F33',
        logoIcon: 'shield',
        players: ['Ninho', 'Cristiano', 'Haaland'],
        captain: 'Ninho',
        goalkeeper: 'Haaland',
        penaltyTaker: 'Cristiano',
        freeKickTaker: 'Ninho',
      ),
      const Team(
        id: 102,
        name: 'Boca Pelada FC',
        primaryColorHex: '#3B82F6',
        secondaryColorHex: '#1E293B',
        logoIcon: 'sports_soccer',
        players: ['Messi', 'Neymar', 'Vinicius Jr'],
        captain: 'Messi',
        goalkeeper: 'Neymar',
        penaltyTaker: 'Messi',
        freeKickTaker: 'Vinicius Jr',
      ),
    ];
  }
}
