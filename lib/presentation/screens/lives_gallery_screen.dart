import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../providers/tournaments_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/primary_button.dart';

class LivesGalleryScreen extends ConsumerWidget {
  const LivesGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournaments = ref.watch(tournamentsProvider);
    final allLives = <Map<String, dynamic>>[];

    for (final t in tournaments) {
      for (final act in t.activities) {
        if (act.liveUrl.isNotEmpty) {
          allLives.add({
            'tournamentName': t.name,
            'tournamentId': t.id,
            'activityName': act.name,
            'activityId': act.id,
            'liveUrl': act.liveUrl,
            'mvp': act.mvp,
            'matchesCount': act.matches.length,
          });
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔴 Lives & Transmissões'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: allLives.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.videocam_off, size: 64, color: AppColors.subtext),
                      SizedBox(height: 16),
                      Text(
                        'Nenhuma Live ou Gravação Cadastrada',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ao criar ou gerenciar rodadas nos torneios, você pode anexar links do YouTube/Twitch/Drive para aparecerem nesta galeria.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.subtext, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: allLives.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = allLives[index];
                    final liveUrl = item['liveUrl'] as String;

                    return CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.primary, width: 1),
                                ),
                                child: Text(
                                  '🏆 ${item['tournamentName']}',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.danger,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.circle, size: 8, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'LIVE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '📅 ${item['activityName']}',
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item['matchesCount']} Partidas ${item['mvp'].toString().isNotEmpty ? '| ⭐ MVP: ${item['mvp']}' : ''}',
                            style: const TextStyle(color: AppColors.subtext, fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          PrimaryButton(
                            label: '🔴 Abrir Link da Transmissão',
                            color: AppColors.danger,
                            icon: Icons.open_in_new,
                            onPressed: () {
                              Share.share('Assista a live/gravação da rodada ${item['activityName']}: $liveUrl');
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
