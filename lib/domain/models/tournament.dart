import 'activity.dart';

class Tournament {
  final int id;
  final String name;
  final String status; // 'active' or 'finished'
  final String gameTemplate;
  final String liveUrl;
  final bool isIndividualMode;
  final List<String> playerNames;
  final List<Activity> activities;

  const Tournament({
    required this.id,
    required this.name,
    this.status = 'active',
    this.gameTemplate = 'football',
    this.liveUrl = '',
    this.isIndividualMode = false,
    required this.playerNames,
    required this.activities,
  });

  bool get isFinished => status == 'finished';

  Tournament copyWith({
    int? id,
    String? name,
    String? status,
    String? gameTemplate,
    String? liveUrl,
    bool? isIndividualMode,
    List<String>? playerNames,
    List<Activity>? activities,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      gameTemplate: gameTemplate ?? this.gameTemplate,
      liveUrl: liveUrl ?? this.liveUrl,
      isIndividualMode: isIndividualMode ?? this.isIndividualMode,
      playerNames: playerNames ?? this.playerNames,
      activities: activities ?? this.activities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'gameTemplate': gameTemplate,
      'liveUrl': liveUrl,
      'isIndividualMode': isIndividualMode,
      'playerNames': playerNames,
      'activities': activities.map((a) => a.toJson()).toList(),
    };
  }

  factory Tournament.fromJson(Map<String, dynamic> json) {
    final rawPlayers = json['playerNames'] as List<dynamic>? ?? [];
    return Tournament(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      gameTemplate: json['gameTemplate']?.toString() ?? 'football',
      liveUrl: json['liveUrl']?.toString() ?? '',
      isIndividualMode: json['isIndividualMode'] ?? false,
      playerNames: List<String>.from(json['playerNames'] ?? []),
      activities: (json['activities'] as List?)
          ?.map((a) => Activity.fromJson(Map<String, dynamic>.from(a as Map)))
          .toList() ??
          [],
    );
  }
}
