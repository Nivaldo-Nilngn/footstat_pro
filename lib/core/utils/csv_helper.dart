import 'dart:convert';
import '../../domain/models/tournament.dart';
import '../../domain/models/activity.dart';
import '../../domain/models/match_record.dart';
import '../../domain/models/match_stats.dart';

class CsvHelper {
  static String generateTournamentCsv(Tournament tournament) {
    final totals = <String, Map<String, int>>{};

    for (final p in tournament.playerNames) {
      totals[p] = {'matches': 0, 'goals': 0, 'assists': 0, 'mvps': 0};
    }

    for (final act in tournament.activities) {
      if (act.mvp.isNotEmpty && totals.containsKey(act.mvp)) {
        totals[act.mvp]!['mvps'] = (totals[act.mvp]!['mvps'] ?? 0) + 1;
      }

      for (final pName in act.participants) {
        if (totals.containsKey(pName)) {
          totals[pName]!['matches'] = (totals[pName]!['matches'] ?? 0) + 1;
        }
      }

      for (final match in act.matches) {
        match.stats.forEach((pName, s) {
          if (totals.containsKey(pName)) {
            totals[pName]!['goals'] = (totals[pName]!['goals'] ?? 0) + s.goals;
            totals[pName]!['assists'] = (totals[pName]!['assists'] ?? 0) + s.assists;
          }
        });
      }
    }

    final buffer = StringBuffer();
    // BOM para Excel UTF-8
    buffer.write('\uFEFF');
    buffer.writeln('Torneio;${tournament.name}');
    buffer.writeln('Jogador;Jogos;Gols;Assistencias;MVPs');

    for (final pName in tournament.playerNames) {
      final p = totals[pName] ?? {'matches': 0, 'goals': 0, 'assists': 0, 'mvps': 0};
      buffer.writeln('"$pName";${p['matches']};${p['goals']};${p['assists']};${p['mvps']}');
    }

    return buffer.toString();
  }

  static Tournament parseTournamentCsv(String csvContent) {
    final lines = csvContent
        .split(RegExp(r'\r\n|\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      throw FormatException('Arquivo CSV vazio ou inválido.');
    }

    final delimiter = lines[0].contains(';') ? ';' : ',';
    String tournamentName = 'Torneio Importado';
    int startIndex = 0;

    final firstCols = lines[0].split(delimiter);
    if (firstCols[0].toLowerCase().contains('torneio')) {
      tournamentName = firstCols.length > 1 ? firstCols[1].replaceAll('"', '').trim() : tournamentName;
      startIndex = 2;
    } else if (firstCols[0].toLowerCase().contains('jogador')) {
      startIndex = 1;
    }

    final name = tournamentName.contains('(Importado)') ? tournamentName : '$tournamentName (Importado)';
    final playerNames = <String>[];
    final importedMatchStats = <String, MatchStats>{};

    for (int i = startIndex; i < lines.length; i++) {
      final cols = lines[i].split(delimiter).map((c) => c.replaceAll('"', '').trim()).toList();
      if (cols.length >= 4) {
        final pName = cols[0];
        if (pName.isNotEmpty && !playerNames.contains(pName)) {
          playerNames.add(pName);
          final goals = int.tryParse(cols.length > 2 ? cols[2] : '0') ?? 0;
          final assists = int.tryParse(cols.length > 3 ? cols[3] : '0') ?? 0;
          importedMatchStats[pName] = MatchStats(customStats: {
            'Gols': goals,
            'Assistências': assists,
          });
        }
      }
    }

    final now = DateTime.now();
    final timeStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    final activity = Activity(
      id: DateTime.now().millisecondsSinceEpoch + 1,
      name: 'Atividade Importada',
      status: 'active',
      participants: List.from(playerNames),
      matches: [
        MatchRecord(
          id: DateTime.now().millisecondsSinceEpoch + 2,
          time: timeStr,
          stats: importedMatchStats,
        ),
      ],
    );

    return Tournament(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      status: 'active',
      playerNames: playerNames,
      activities: [activity],
    );
  }
}
