import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/tournament.dart';

class StorageRepository {
  static const String _keyGlobalPlayers = 'football_global_players';
  static const String _keyTournaments = 'football_tournaments';

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
}
