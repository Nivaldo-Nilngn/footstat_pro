import 'match_stats.dart';

class MatchRecord {
  final int id;
  final String time;
  final Map<String, MatchStats> stats;

  const MatchRecord({
    required this.id,
    required this.time,
    required this.stats,
  });

  MatchRecord copyWith({
    int? id,
    String? time,
    Map<String, MatchStats>? stats,
  }) {
    return MatchRecord(
      id: id ?? this.id,
      time: time ?? this.time,
      stats: stats ?? this.stats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'stats': stats.map((key, value) => MapEntry(key, value.toJson())),
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

    return MatchRecord(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      time: json['time']?.toString() ?? '',
      stats: parsedStats,
    );
  }
}
