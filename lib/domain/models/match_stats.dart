class MatchStats {
  final int shirtNumber;
  final List<int> goalTimestamps;
  final bool isMvp;
  final Map<String, int> customStats;

  const MatchStats({
    this.shirtNumber = 0,
    this.goalTimestamps = const [],
    this.isMvp = false,
    this.customStats = const {},
  });

  // Retro-compatibility getters for the rest of the application
  int get goals => customStats['Gols'] ?? 0;
  int get assists => customStats['Assistências'] ?? 0;
  int get fouls => customStats['Faltas'] ?? 0;
  int get yellowCards => customStats['Cartões Amarelos'] ?? 0;
  int get redCards => customStats['Cartões Vermelhos'] ?? 0;

  MatchStats copyWith({
    int? shirtNumber,
    List<int>? goalTimestamps,
    bool? isMvp,
    Map<String, int>? customStats,
    // Legacy setters for compatibility during Match record/simulate
    int? goals,
    int? assists,
    int? fouls,
    int? yellowCards,
    int? redCards,
  }) {
    final Map<String, int> updatedStats = Map.from(this.customStats);
    if (customStats != null) {
      updatedStats.addAll(customStats);
    } else {
      if (goals != null) updatedStats['Gols'] = goals;
      if (assists != null) updatedStats['Assistências'] = assists;
      if (fouls != null) updatedStats['Faltas'] = fouls;
      if (yellowCards != null) updatedStats['Cartões Amarelos'] = yellowCards;
      if (redCards != null) updatedStats['Cartões Vermelhos'] = redCards;
    }

    return MatchStats(
      shirtNumber: shirtNumber ?? this.shirtNumber,
      goalTimestamps: goalTimestamps ?? this.goalTimestamps,
      isMvp: isMvp ?? this.isMvp,
      customStats: updatedStats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shirtNumber': shirtNumber,
      'goalTimestamps': goalTimestamps,
      'isMvp': isMvp,
      'customStats': customStats,
    };
  }

  factory MatchStats.fromJson(Map<String, dynamic> json) {
    final rawList = json['goalTimestamps'] as List<dynamic>? ?? [];
    
    // Check if it's legacy format
    Map<String, int> parsedStats = {};
    if (json.containsKey('customStats')) {
      final map = json['customStats'] as Map<dynamic, dynamic>? ?? {};
      parsedStats = map.map((key, value) => MapEntry(key.toString(), value is int ? value : int.tryParse(value.toString()) ?? 0));
    } else {
      parsedStats['Gols'] = json['goals'] is int ? json['goals'] as int : int.tryParse(json['goals']?.toString() ?? '0') ?? 0;
      parsedStats['Assistências'] = json['assists'] is int ? json['assists'] as int : int.tryParse(json['assists']?.toString() ?? '0') ?? 0;
      parsedStats['Faltas'] = json['fouls'] is int ? json['fouls'] as int : int.tryParse(json['fouls']?.toString() ?? '0') ?? 0;
      parsedStats['Cartões Amarelos'] = json['yellowCards'] is int ? json['yellowCards'] as int : int.tryParse(json['yellowCards']?.toString() ?? '0') ?? 0;
      parsedStats['Cartões Vermelhos'] = json['redCards'] is int ? json['redCards'] as int : int.tryParse(json['redCards']?.toString() ?? '0') ?? 0;
    }

    return MatchStats(
      shirtNumber: json['shirtNumber'] is int ? json['shirtNumber'] as int : int.tryParse(json['shirtNumber']?.toString() ?? '0') ?? 0,
      goalTimestamps: rawList.map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0).toList(),
      isMvp: json['isMvp'] as bool? ?? false,
      customStats: parsedStats,
    );
  }
}
