import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/players_provider.dart';
import '../providers/teams_provider.dart';
import '../providers/tournaments_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/primary_button.dart';
import 'main_shell_screen.dart';

class CreateTournamentScreen extends ConsumerStatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  ConsumerState<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends ConsumerState<CreateTournamentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final Set<int> _selectedTeamIds = {};
  final Set<String> _selectedIndividualPlayers = {};
  bool _useTeamsMode = true;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  void _createTournament() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o nome do torneio!')),
      );
      return;
    }

    final teams = ref.read(teamsProvider);
    final Set<String> allTournamentPlayers = {};

    if (_useTeamsMode) {
      if (_selectedTeamIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione ao menos 1 time para o torneio!')),
        );
        return;
      }

      for (final tId in _selectedTeamIds) {
        final tList = teams.where((t) => t.id == tId).toList();
        if (tList.isNotEmpty) {
          allTournamentPlayers.addAll(tList.first.players);
        }
      }
    } else {
      if (_selectedIndividualPlayers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione ao menos 1 jogador!')),
        );
        return;
      }
      allTournamentPlayers.addAll(_selectedIndividualPlayers);
    }

    if (allTournamentPlayers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Os times selecionados precisam ter jogadores cadastrados!')),
      );
      return;
    }

    await ref.read(tournamentsProvider.notifier).createTournament(
          name,
          allTournamentPlayers.toList(),
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Torneio "$name" criado com sucesso! 🏆')),
      );
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        ref.read(activeTabProvider.notifier).state = ActiveTab.tournaments;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final teams = ref.watch(teamsProvider);
    final globalPlayers = ref.watch(playersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('➕ Criar Torneio'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nome do Torneio / Campeonato',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Ex: Copa dos Campeões 2026',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Mode Selector Tabs (Times do Banco vs Jogadores Avulsos)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _useTeamsMode = true),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _useTeamsMode ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '🛡️ Times do Banco (${teams.length})',
                              style: TextStyle(
                                color: _useTeamsMode ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _useTeamsMode = false),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_useTeamsMode ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '👤 Jogadores Avulsos',
                              style: TextStyle(
                                color: !_useTeamsMode ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Teams Selection List
              if (_useTeamsMode) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SELECIONE OS TIMES PARTICIPANTES',
                      style: TextStyle(
                        color: AppColors.subtext,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (teams.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            if (_selectedTeamIds.length == teams.length) {
                              _selectedTeamIds.clear();
                            } else {
                              _selectedTeamIds.addAll(teams.map((t) => t.id));
                            }
                          });
                        },
                        child: Text(
                          _selectedTeamIds.length == teams.length ? 'Desmarcar Todos' : 'Selecionar Todos',
                          style: const TextStyle(color: AppColors.primary, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: teams.isEmpty
                      ? const CustomCard(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'Nenhum time cadastrado no Banco de Times.\nCadastre os times na aba "Banco de Times" primeiro.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.subtext),
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: teams.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final t = teams[index];
                            final isSelected = _selectedTeamIds.contains(t.id);
                            final teamColor = _parseColor(t.primaryColorHex);

                            return CustomCard(
                              padding: const EdgeInsets.all(12),
                              child: CheckboxListTile(
                                activeColor: teamColor,
                                checkColor: Colors.white,
                                title: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: teamColor.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: teamColor, width: 1.5),
                                      ),
                                      child: const Icon(Icons.shield, color: Colors.white, size: 14),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        t.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4, left: 38),
                                  child: Text(
                                    t.players.isEmpty
                                        ? '⚠️ Sem jogadores cadastrados'
                                        : 'Elenco: ${t.players.join(", ")}',
                                    style: TextStyle(
                                      color: t.players.isEmpty ? AppColors.danger : AppColors.subtext,
                                      fontSize: 11,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                value: isSelected,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selectedTeamIds.add(t.id);
                                    } else {
                                      _selectedTeamIds.remove(t.id);
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),
                ),
              ] else ...[
                // Individual Players Mode List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SELECIONE OS JOGADORES',
                      style: TextStyle(
                        color: AppColors.subtext,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (globalPlayers.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            if (_selectedIndividualPlayers.length == globalPlayers.length) {
                              _selectedIndividualPlayers.clear();
                            } else {
                              _selectedIndividualPlayers.addAll(globalPlayers);
                            }
                          });
                        },
                        child: Text(
                          _selectedIndividualPlayers.length == globalPlayers.length ? 'Desmarcar Todos' : 'Selecionar Todos',
                          style: const TextStyle(color: AppColors.primary, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: globalPlayers.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum jogador cadastrado.',
                            style: TextStyle(color: AppColors.subtext),
                          ),
                        )
                      : ListView.separated(
                          itemCount: globalPlayers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            final pName = globalPlayers[index];
                            final isSelected = _selectedIndividualPlayers.contains(pName);

                            return CustomCard(
                              padding: EdgeInsets.zero,
                              child: CheckboxListTile(
                                activeColor: AppColors.primary,
                                checkColor: Colors.white,
                                title: Text(pName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                value: isSelected,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selectedIndividualPlayers.add(pName);
                                    } else {
                                      _selectedIndividualPlayers.remove(pName);
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],

              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Criar Torneio',
                icon: Icons.check,
                onPressed: _createTournament,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
