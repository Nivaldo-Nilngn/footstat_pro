import 'match_record.dart';

class Activity {
  final int id;
  final String name;
  final String status; // 'active' or 'finished'
  final String mvp;
  final String liveUrl;
  final String gameTemplate;
  final List<String> activeMetrics;
  final List<String> participants;
  final List<MatchRecord> matches;

  const Activity({
    required this.id,
    required this.name,
    this.status = 'active',
    this.mvp = '',
    this.liveUrl = '',
    this.gameTemplate = 'football',
    this.activeMetrics = const ['Gols', 'Assistências', 'Cartões Amarelos', 'Cartões Vermelhos', 'Faltas'],
    required this.participants,
    required this.matches,
  });

  bool get isFinished => status == 'finished';

  Activity copyWith({
    int? id,
    String? name,
    String? status,
    String? mvp,
    String? liveUrl,
    String? gameTemplate,
    List<String>? activeMetrics,
    List<String>? participants,
    List<MatchRecord>? matches,
  }) {
    return Activity(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      mvp: mvp ?? this.mvp,
      liveUrl: liveUrl ?? this.liveUrl,
      gameTemplate: gameTemplate ?? this.gameTemplate,
      activeMetrics: activeMetrics ?? this.activeMetrics,
      participants: participants ?? this.participants,
      matches: matches ?? this.matches,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'mvp': mvp,
      'liveUrl': liveUrl,
      'gameTemplate': gameTemplate,
      'activeMetrics': activeMetrics,
      'participants': participants,
      'matches': matches.map((m) => m.toJson()).toList(),
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    final rawParticipants = json['participants'] as List<dynamic>? ?? [];
    final rawMatches = json['matches'] as List<dynamic>? ?? [];
    final rawMetrics = json['activeMetrics'] as List<dynamic>? ?? ['Gols', 'Assistências', 'Cartões Amarelos', 'Cartões Vermelhos', 'Faltas'];

    return Activity(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      mvp: json['mvp']?.toString() ?? '',
      liveUrl: json['liveUrl']?.toString() ?? '',
      gameTemplate: json['gameTemplate']?.toString() ?? 'football',
      activeMetrics: rawMetrics.map((e) => e.toString()).toList(),
      participants: rawParticipants.map((e) => e.toString()).toList(),
      matches: rawMatches.map((m) {
        final mMap = m is Map<String, dynamic> ? m : Map<String, dynamic>.from(m as Map);
        return MatchRecord.fromJson(mMap);
      }).toList(),
    );
  }
}
