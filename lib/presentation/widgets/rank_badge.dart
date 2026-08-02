import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum RankType { goals, assists, matches, mvp }

class RankBadge extends StatelessWidget {
  final RankType type;
  final String label;

  const RankBadge({
    super.key,
    required this.type,
    required this.label,
  });

  Color get _badgeColor {
    switch (type) {
      case RankType.goals:
        return AppColors.badgeGoals;
      case RankType.assists:
        return AppColors.badgeAssists;
      case RankType.matches:
        return AppColors.badgeMatches;
      case RankType.mvp:
        return AppColors.badgeMvp;
    }
  }

  IconData get _icon {
    switch (type) {
      case RankType.goals:
        return Icons.sports_soccer;
      case RankType.assists:
        return Icons.directions_run;
      case RankType.matches:
        return Icons.sports;
      case RankType.mvp:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _badgeColor.withOpacity(0.15),
        border: Border.all(color: _badgeColor, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: _badgeColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: _badgeColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
