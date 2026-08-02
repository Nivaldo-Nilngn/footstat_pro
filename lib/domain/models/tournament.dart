import 'activity.dart';

class Tournament {
  final int id;
  final String name;
  final String status; // 'active' or 'finished'
  final List<String> playerNames;
  final List<Activity> activities;

  const Tournament({
    required this.id,
    required this.name,
    this.status = 'active',
    required this.playerNames,
    required this.activities,
  });

  bool get isFinished => status == 'finished';

  Tournament copyWith({
    int? id,
    String? name,
    String? status,
    List<String>? playerNames,
    List<Activity>? activities,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      playerNames: playerNames ?? this.playerNames,
      activities: activities ?? this.activities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'playerNames': playerNames,
      'activities': activities.map((a) => a.toJson()).toList(),
    };
  }

  factory Tournament.fromJson(Map<String, dynamic> json) {
    final rawPlayers = json['playerNames'] as List<dynamic>? ?? [];
    final rawActivities = json['activities'] as List<dynamic>? ?? [];

    return Tournament(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      playerNames: rawPlayers.map((e) => e.toString()).toList(),
      activities: rawActivities.map((a) {
        final aMap = a is Map<String, dynamic> ? a : Map<String, dynamic>.from(a as Map);
        return Activity.fromJson(aMap);
      }).toList(),
    );
  }
}
