import 'match_record.dart';

class Activity {
  final int id;
  final String name;
  final String status; // 'active' or 'finished'
  final String mvp;
  final String liveUrl;
  final List<String> participants;
  final List<MatchRecord> matches;

  const Activity({
    required this.id,
    required this.name,
    this.status = 'active',
    this.mvp = '',
    this.liveUrl = '',
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
    List<String>? participants,
    List<MatchRecord>? matches,
  }) {
    return Activity(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      mvp: mvp ?? this.mvp,
      liveUrl: liveUrl ?? this.liveUrl,
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
      'participants': participants,
      'matches': matches.map((m) => m.toJson()).toList(),
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    final rawParticipants = json['participants'] as List<dynamic>? ?? [];
    final rawMatches = json['matches'] as List<dynamic>? ?? [];

    return Activity(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      mvp: json['mvp']?.toString() ?? '',
      liveUrl: json['liveUrl']?.toString() ?? '',
      participants: rawParticipants.map((e) => e.toString()).toList(),
      matches: rawMatches.map((m) {
        final mMap = m is Map<String, dynamic> ? m : Map<String, dynamic>.from(m as Map);
        return MatchRecord.fromJson(mMap);
      }).toList(),
    );
  }
}
