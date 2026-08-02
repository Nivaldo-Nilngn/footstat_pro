class MatchStats {
  final int shirtNumber;
  final int goals;
  final int assists;
  final int fouls;
  final int yellowCards;
  final int redCards;
  final List<int> goalTimestamps;
  final bool isMvp;

  const MatchStats({
    this.shirtNumber = 0,
    this.goals = 0,
    this.assists = 0,
    this.fouls = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.goalTimestamps = const [],
    this.isMvp = false,
  });

  MatchStats copyWith({
    int? shirtNumber,
    int? goals,
    int? assists,
    int? fouls,
    int? yellowCards,
    int? redCards,
    List<int>? goalTimestamps,
    bool? isMvp,
  }) {
    return MatchStats(
      shirtNumber: shirtNumber ?? this.shirtNumber,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      fouls: fouls ?? this.fouls,
      yellowCards: yellowCards ?? this.yellowCards,
      redCards: redCards ?? this.redCards,
      goalTimestamps: goalTimestamps ?? this.goalTimestamps,
      isMvp: isMvp ?? this.isMvp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shirtNumber': shirtNumber,
      'goals': goals,
      'assists': assists,
      'fouls': fouls,
      'yellowCards': yellowCards,
      'redCards': redCards,
      'goalTimestamps': goalTimestamps,
      'isMvp': isMvp,
    };
  }

  factory MatchStats.fromJson(Map<String, dynamic> json) {
    final rawList = json['goalTimestamps'] as List<dynamic>? ?? [];
    return MatchStats(
      shirtNumber: json['shirtNumber'] is int ? json['shirtNumber'] as int : int.tryParse(json['shirtNumber']?.toString() ?? '0') ?? 0,
      goals: json['goals'] is int ? json['goals'] as int : int.tryParse(json['goals']?.toString() ?? '0') ?? 0,
      assists: json['assists'] is int ? json['assists'] as int : int.tryParse(json['assists']?.toString() ?? '0') ?? 0,
      fouls: json['fouls'] is int ? json['fouls'] as int : int.tryParse(json['fouls']?.toString() ?? '0') ?? 0,
      yellowCards: json['yellowCards'] is int ? json['yellowCards'] as int : int.tryParse(json['yellowCards']?.toString() ?? '0') ?? 0,
      redCards: json['redCards'] is int ? json['redCards'] as int : int.tryParse(json['redCards']?.toString() ?? '0') ?? 0,
      goalTimestamps: rawList.map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0).toList(),
      isMvp: json['isMvp'] as bool? ?? false,
    );
  }
}
