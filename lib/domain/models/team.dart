class Team {
  final int id;
  final String name;
  final String primaryColorHex;
  final String secondaryColorHex;
  final String logoIcon;
  final List<String> players;
  final Map<String, int> shirtNumbers;
  final Map<String, String> playerPositions;
  final String captain;
  final String goalkeeper;
  final String penaltyTaker;
  final String freeKickTaker;

  const Team({
    required this.id,
    required this.name,
    this.primaryColorHex = '#3B82F6',
    this.secondaryColorHex = '#171F33',
    this.logoIcon = 'shield',
    this.players = const [],
    this.shirtNumbers = const {},
    this.playerPositions = const {},
    this.captain = '',
    this.goalkeeper = '',
    this.penaltyTaker = '',
    this.freeKickTaker = '',
  });

  Team copyWith({
    int? id,
    String? name,
    String? primaryColorHex,
    String? secondaryColorHex,
    String? logoIcon,
    List<String>? players,
    Map<String, int>? shirtNumbers,
    Map<String, String>? playerPositions,
    String? captain,
    String? goalkeeper,
    String? penaltyTaker,
    String? freeKickTaker,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      secondaryColorHex: secondaryColorHex ?? this.secondaryColorHex,
      logoIcon: logoIcon ?? this.logoIcon,
      players: players ?? this.players,
      shirtNumbers: shirtNumbers ?? this.shirtNumbers,
      playerPositions: playerPositions ?? this.playerPositions,
      captain: captain ?? this.captain,
      goalkeeper: goalkeeper ?? this.goalkeeper,
      penaltyTaker: penaltyTaker ?? this.penaltyTaker,
      freeKickTaker: freeKickTaker ?? this.freeKickTaker,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'primaryColorHex': primaryColorHex,
      'secondaryColorHex': secondaryColorHex,
      'logoIcon': logoIcon,
      'players': players,
      'shirtNumbers': shirtNumbers,
      'playerPositions': playerPositions,
      'captain': captain,
      'goalkeeper': goalkeeper,
      'penaltyTaker': penaltyTaker,
      'freeKickTaker': freeKickTaker,
    };
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    final rawPlayers = (json['players'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    final rawShirts = json['shirtNumbers'] as Map<String, dynamic>? ?? {};
    final parsedShirts = rawShirts.map((k, v) => MapEntry(k, v is int ? v : int.tryParse(v.toString()) ?? 10));

    final rawPositions = json['playerPositions'] as Map<String, dynamic>? ?? {};
    final parsedPositions = rawPositions.map((k, v) => MapEntry(k, v.toString()));

    return Team(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? 'Novo Time',
      primaryColorHex: json['primaryColorHex']?.toString() ?? '#3B82F6',
      secondaryColorHex: json['secondaryColorHex']?.toString() ?? '#171F33',
      logoIcon: json['logoIcon']?.toString() ?? 'shield',
      players: rawPlayers,
      shirtNumbers: parsedShirts,
      playerPositions: parsedPositions,
      captain: json['captain']?.toString() ?? '',
      goalkeeper: json['goalkeeper']?.toString() ?? '',
      penaltyTaker: json['penaltyTaker']?.toString() ?? '',
      freeKickTaker: json['freeKickTaker']?.toString() ?? '',
    );
  }
}
