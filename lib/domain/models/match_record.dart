import 'match_stats.dart';

class MatchRecord {
  final int id;
  final String time;
  final String teamAName;
  final String teamBName;
  final int durationMinutes;
  final List<String> teamAPlayers;
  final List<String> teamBPlayers;
  final List<Map<String, dynamic>> timelineEvents;
  final Map<String, MatchStats> stats;
  final String matchDate;
  final String matchTime;
  final String location;
  final String status; // 'scheduled', 'live', 'finished'

  const MatchRecord({
    required this.id,
    required this.time,
    this.teamAName = 'Time A',
    this.teamBName = 'Time B',
    this.durationMinutes = 15,
    this.teamAPlayers = const [],
    this.teamBPlayers = const [],
    this.timelineEvents = const [],
    required this.stats,
    this.matchDate = '',
    this.matchTime = '',
    this.location = '',
    this.status = 'finished',
  });

  MatchRecord copyWith({
    int? id,
    String? time,
    String? teamAName,
    String? teamBName,
    int? durationMinutes,
    List<String>? teamAPlayers,
    List<String>? teamBPlayers,
    List<Map<String, dynamic>>? timelineEvents,
    Map<String, MatchStats>? stats,
    String? matchDate,
    String? matchTime,
    String? location,
    String? status,
  }) {
    return MatchRecord(
      id: id ?? this.id,
      time: time ?? this.time,
      teamAName: teamAName ?? this.teamAName,
      teamBName: teamBName ?? this.teamBName,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      teamAPlayers: teamAPlayers ?? this.teamAPlayers,
      teamBPlayers: teamBPlayers ?? this.teamBPlayers,
      timelineEvents: timelineEvents ?? this.timelineEvents,
      stats: stats ?? this.stats,
      matchDate: matchDate ?? this.matchDate,
      matchTime: matchTime ?? this.matchTime,
      location: location ?? this.location,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'teamAName': teamAName,
      'teamBName': teamBName,
      'durationMinutes': durationMinutes,
      'teamAPlayers': teamAPlayers,
      'teamBPlayers': teamBPlayers,
      'timelineEvents': timelineEvents,
      'stats': stats.map((key, value) => MapEntry(key, value.toJson())),
      'matchDate': matchDate,
      'matchTime': matchTime,
      'location': location,
      'status': status,
    };
  }

  factory MatchRecord.fromJson(Map<String, dynamic> json) {
    final rawStats = json['stats'] as Map<String, dynamic>? ?? {};
    final parsedStats = rawStats.map((key, value) {
      final statsMap = value is Map<String, dynamic>
          ? value
          : Map<String, dynamic>.from(value as Map);
      return MapEntry(key, MatchStats.fromJson(statsMap));
    });

    final rawTeamA = (json['teamAPlayers'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final rawTeamB = (json['teamBPlayers'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final rawEvents = (json['timelineEvents'] as List<dynamic>?)
            ?.map((e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];

    return MatchRecord(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      time: json['time']?.toString() ?? '',
      teamAName: json['teamAName']?.toString() ?? 'Time A',
      teamBName: json['teamBName']?.toString() ?? 'Time B',
      durationMinutes: json['durationMinutes'] is int ? json['durationMinutes'] as int : 15,
      teamAPlayers: rawTeamA,
      teamBPlayers: rawTeamB,
      timelineEvents: rawEvents,
      stats: parsedStats,
      matchDate: json['matchDate']?.toString() ?? '',
      matchTime: json['matchTime']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      status: json['status']?.toString() ?? 'finished',
    );
  }
}
