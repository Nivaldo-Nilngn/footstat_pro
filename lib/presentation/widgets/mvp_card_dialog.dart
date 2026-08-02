import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

class MvpCardDialog extends StatelessWidget {
  final String playerName;
  final String titleName;
  final int goals;
  final int assists;
  final int wins;
  final int totalMatches;

  const MvpCardDialog({
    super.key,
    required this.playerName,
    this.titleName = 'CRAQUE DA RODADA',
    required this.goals,
    required this.assists,
    required this.wins,
    required this.totalMatches,
  });

  void _copyMvpCardToClipboard(BuildContext context) {
    final String text = '''
🏆 *CRAQUE DA RODADA - FOOTSTAT PRO* 🌟
────────────────────────
⭐ *Jogador:* $playerName
⚽ *Gols:* $goals
🎯 *Assistências:* $assists
🔥 *Vitórias:* $wins em $totalMatches jogos

Feras do Torneio! 🚀
''';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Card de MVP copiado para enviar no WhatsApp! 📲'),
        backgroundColor: AppColors.gold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = playerName.isNotEmpty ? playerName[0].toUpperCase() : '⭐';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1326),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.gold, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.35),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Badge Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.gold.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: AppColors.gold, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    titleName.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.star, color: AppColors.gold, size: 16),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Large Player Avatar Circle
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.2),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emoji_events, color: Colors.black, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Player Name
            Text(
              playerName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'DESTAQUE MÁXIMO DA PARTIDA',
              style: TextStyle(
                color: AppColors.subtext,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 24),

            // FIFA-style Stats Grid Cards
            Row(
              children: [
                Expanded(
                  child: _MvpStatTile(
                    label: 'GOLS',
                    value: '$goals',
                    icon: Icons.sports_soccer,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MvpStatTile(
                    label: 'ASSISTÊNCIAS',
                    value: '$assists',
                    icon: Icons.sports_score,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MvpStatTile(
                    label: 'VITÓRIAS',
                    value: '$wins',
                    icon: Icons.thumb_up,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyMvpCardToClipboard(context),
                    icon: const Icon(Icons.share, color: AppColors.gold, size: 18),
                    label: const Text('WhatsApp', style: TextStyle(color: AppColors.gold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.gold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Fechar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MvpStatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MvpStatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.subtext,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
