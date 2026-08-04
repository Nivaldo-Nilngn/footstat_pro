enum GameTemplate {
  football,
  brawlStars,
  moba,
  shooter
}

class TemplateMetrics {
  static const Map<GameTemplate, List<String>> metrics = {
    GameTemplate.football: ['Gols', 'Assistências', 'Cartões Amarelos', 'Cartões Vermelhos', 'Faltas'],
    GameTemplate.brawlStars: ['Dano', 'Kills', 'Cura', 'Estrelas'],
    GameTemplate.moba: ['Kills', 'Mortes', 'Assistências', 'Farm (CS)'],
    GameTemplate.shooter: ['Kills', 'Headshots', 'Dano', 'Booyahs'],
  };

  static String getName(GameTemplate template) {
    switch (template) {
      case GameTemplate.football:
        return 'Futebol / Society';
      case GameTemplate.brawlStars:
        return 'Brawl Stars';
      case GameTemplate.moba:
        return 'MOBA (LoL, Wild Rift)';
      case GameTemplate.shooter:
        return 'Shooter (Free Fire, Valorant)';
    }
  }
}
