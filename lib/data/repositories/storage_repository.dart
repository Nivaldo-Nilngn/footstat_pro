import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/tournament.dart';
import '../../domain/models/team.dart';

class StorageRepository {
  static const String _keyGlobalPlayers = 'football_global_players';
  static const String _keyTournaments = 'football_tournaments';
  static const String _keyTeams = 'football_teams';

  Future<List<String>> loadGlobalPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyGlobalPlayers);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveGlobalPlayers(List<String> players) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGlobalPlayers, jsonEncode(players));
  }

  Future<List<Tournament>> loadTournaments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyTournaments);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((item) {
        final map = item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item as Map);
        return Tournament.fromJson(map);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTournaments(List<Tournament> tournaments) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = tournaments.map((t) => t.toJson()).toList();
    await prefs.setString(_keyTournaments, jsonEncode(jsonList));
  }

  Future<List<Team>> loadTeams() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyTeams);
    if (jsonStr == null || jsonStr.isEmpty) {
      // Default initial seed teams
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

    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((item) {
        final map = item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item as Map);
        return Team.fromJson(map);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTeams(List<Team> teams) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = teams.map((t) => t.toJson()).toList();
    await prefs.setString(_keyTeams, jsonEncode(jsonList));
  }
}
