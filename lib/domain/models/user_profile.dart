class UserProfile {
  final String id;
  final String name;
  final String avatarUrl;
  final int level;
  final int currentXp;
  final int maxXpForLevel;
  final bool isVerified;
  final String badgeType; // 'none', 'gold', 'blue', 'pro'
  final List<String> achievements;
  final String tag;

  UserProfile({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.level,
    required this.currentXp,
    required this.maxXpForLevel,
    this.isVerified = false,
    this.badgeType = 'none',
    this.achievements = const [],
    this.tag = '#000000',
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    int? level,
    int? currentXp,
    int? maxXpForLevel,
    bool? isVerified,
    String? badgeType,
    List<String>? achievements,
    String? tag,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      maxXpForLevel: maxXpForLevel ?? this.maxXpForLevel,
      isVerified: isVerified ?? this.isVerified,
      badgeType: badgeType ?? this.badgeType,
      achievements: achievements ?? this.achievements,
      tag: tag ?? this.tag,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'level': level,
      'currentXp': currentXp,
      'maxXpForLevel': maxXpForLevel,
      'isVerified': isVerified,
      'badgeType': badgeType,
      'achievements': achievements,
      'tag': tag,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String,
      level: json['level'] as int,
      currentXp: json['currentXp'] as int,
      maxXpForLevel: json['maxXpForLevel'] as int,
      isVerified: json['isVerified'] as bool? ?? false,
      badgeType: json['badgeType'] as String? ?? 'none',
      achievements: (json['achievements'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      tag: json['tag'] as String? ?? '#000000',
    );
  }
}
