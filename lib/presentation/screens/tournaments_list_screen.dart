import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/tournaments_provider.dart';
import '../widgets/custom_card.dart';
import 'tournament_details_screen.dart';

class TournamentsListScreen extends ConsumerWidget {
  const TournamentsListScreen({super.key});

  void _renameTournament(BuildContext context, WidgetRef ref, int id, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Renomear Torneio', style: TextStyle(color: AppColors.primary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Novo nome do torneio'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.subtext)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != currentName) {
      await ref.read(tournamentsProvider.notifier).renameTournament(id, newName);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Torneio renomeado para "$newName"')),
        );
      }
    }
  }

  void _deleteTournament(BuildContext context, WidgetRef ref, int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Excluir Torneio', style: TextStyle(color: AppColors.danger)),
        content: Text('Excluir o torneio "$name"? Todas as rodadas e estatísticas registradas serão apagadas.', style: const TextStyle(color: AppColors.text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.subtext)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(tournamentsProvider.notifier).deleteTournament(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Torneio "$name" excluído.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournaments = ref.watch(tournamentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Meus Torneios'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: tournaments.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum torneio criado ainda.',
                    style: TextStyle(color: AppColors.subtext),
                  ),
                )
              : ListView.separated(
                  itemCount: tournaments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final t = tournaments[index];
                    return CustomCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TournamentDetailsScreen(tournamentId: t.id),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.emoji_events, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  t.name,
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (t.isFinished)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.dangerBg,
                                    border: Border.all(color: AppColors.danger),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'FINALIZADO',
                                    style: TextStyle(
                                      color: AppColors.danger,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${t.playerNames.length} Jogadores | ${t.activities.length} Atividades',
                            style: const TextStyle(
                              color: AppColors.subtext,
                              fontSize: 13,
                            ),
                          ),
                          const Divider(color: AppColors.border, height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _renameTournament(context, ref, t.id, t.name),
                                    icon: const Icon(Icons.edit, size: 16, color: AppColors.subtext),
                                    label: const Text('Renomear', style: TextStyle(color: AppColors.subtext, fontSize: 13)),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _deleteTournament(context, ref, t.id, t.name),
                                    icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                                    label: const Text('Excluir', style: TextStyle(color: AppColors.danger, fontSize: 13)),
                                  ),
                                ],
                              ),
                              Row(
                                children: const [
                                  Text(
                                    'Abrir',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward, color: AppColors.primary, size: 16),
                                ],
                              ),
                            ],
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
