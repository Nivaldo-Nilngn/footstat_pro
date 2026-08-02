class MatchStats {
  final int goals;
  final int assists;

  const MatchStats({
    this.goals = 0,
    this.assists = 0,
  });

  MatchStats copyWith({
    int? goals,
    int? assists,
  }) {
    return MatchStats(
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goals': goals,
      'assists': assists,
    };
  }

  factory MatchStats.fromJson(Map<String, dynamic> json) {
    return MatchStats(
      goals: json['goals'] is int ? json['goals'] as int : int.tryParse(json['goals']?.toString() ?? '0') ?? 0,
      assists: json['assists'] is int ? json['assists'] as int : int.tryParse(json['assists']?.toString() ?? '0') ?? 0,
    );
  }
}
