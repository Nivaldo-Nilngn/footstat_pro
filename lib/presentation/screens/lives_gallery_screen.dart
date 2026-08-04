import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/tournaments_provider.dart';
import 'live_hub_screen.dart';

class LivesGalleryScreen extends ConsumerWidget {
  const LivesGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournaments = ref.watch(tournamentsProvider);
    final allLives = <Map<String, dynamic>>[];

    for (final t in tournaments) {
      if (t.liveUrl.isNotEmpty) {
        allLives.add({
          'tournamentName': t.name,
          'tournamentId': t.id,
          'activityName': 'Cobertura do Torneio',
          'activityId': null,
          'liveUrl': t.liveUrl,
          'mvp': null,
          'matchesCount': 0,
          'players': t.playerNames,
        });
      }
      
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
            'players': act.matches.expand((m) => [...m.teamAPlayers, ...m.teamBPlayers]).toSet().toList(),
          });
        }
      }
    }

    if (allLives.isEmpty) {
      allLives.addAll([
        {
          'tournamentName': 'Copa Elite Pro 2026',
          'activityName': 'Grande Final: INTZ vs LOUD',
          'liveUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
          'players': ['Robo', 'Croc', 'tinowns', 'Route', 'Ceos', 'Tay', 'Cariok', 'dyNquedo', 'NinjaKiwi', 'Damage'],
        },
        {
          'tournamentName': 'Liga Amadora Regional',
          'activityName': 'Semifinal de Futsal',
          'liveUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
          'players': ['João', 'Pedro', 'Lucas', 'Mateus'],
        },
        {
          'tournamentName': 'Free Fire Showdown',
          'activityName': 'Queda #4 (Bermuda)',
          'liveUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
          'players': ['Nobru', 'Cerol', 'Weedzao', 'Bak'],
        },
      ]);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('🔴 Live Hub & eSports'),
        backgroundColor: AppColors.cardBackground,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transmissões em Alta',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Acompanhe as partidas ao vivo e vote no MVP da Galera!',
                style: TextStyle(color: AppColors.subtext),
              ),
              const SizedBox(height: 24),
              
              Expanded(
                child: allLives.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.videocam_off, size: 64, color: AppColors.subtext),
                            SizedBox(height: 16),
                            Text(
                              'Nenhuma Live Cadastrada no Momento',
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          childAspectRatio: 16 / 11,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: allLives.length,
                        itemBuilder: (context, index) {
                          final live = allLives[index];
                          return _buildLiveCard(context, live);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveCard(BuildContext context, Map<String, dynamic> live) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LiveHubScreen(liveData: live),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=2070&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: AppColors.surfaceHigh),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 8),
                          SizedBox(width: 4),
                          Text('AO VIVO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Text(
                      live['activityName'] ?? 'Partida',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: const Icon(Icons.emoji_events, size: 16, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          live['tournamentName'] ?? 'Torneio',
                          style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'League Oficial',
                          style: TextStyle(color: AppColors.subtext, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
