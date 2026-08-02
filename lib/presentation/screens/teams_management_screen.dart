import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/players_provider.dart';
import '../providers/teams_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/primary_button.dart';

class TeamsManagementScreen extends ConsumerStatefulWidget {
  const TeamsManagementScreen({super.key});

  @override
  ConsumerState<TeamsManagementScreen> createState() => _TeamsManagementScreenState();
}

class _TeamsManagementScreenState extends ConsumerState<TeamsManagementScreen> {
  final TextEditingController _teamNameController = TextEditingController();
  String _selectedPrimaryColor = '#FF4D4D';
  String _selectedLogoIcon = 'shield';

  @override
  void dispose() {
    _teamNameController.dispose();
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

  IconData _getIconData(String name) {
    switch (name) {
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'bolt':
        return Icons.bolt;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'star':
        return Icons.star;
      case 'shield':
      default:
        return Icons.shield;
    }
  }

  void _openCreateTeamDialog() {
    _teamNameController.clear();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.border),
            ),
            title: const Row(
              children: [
                Icon(Icons.shield, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Criar Novo Time', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _teamNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Time (Ex: Tigres FC)',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Cor Principal do Uniforme:', style: TextStyle(color: AppColors.subtext, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['#FF4D4D', '#3B82F6', '#4EDEA3', '#A855F7', '#FFD700', '#FF9800'].map((hex) {
                    final isSel = _selectedPrimaryColor == hex;
                    return InkWell(
                      onTap: () {
                        setDialogState(() => _selectedPrimaryColor = hex);
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _parseColor(hex),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSel ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Escudo do Time:', style: TextStyle(color: AppColors.subtext, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['shield', 'sports_soccer', 'bolt', 'local_fire_department', 'star'].map((iconName) {
                    final isSel = _selectedLogoIcon == iconName;
                    return InkWell(
                      onTap: () {
                        setDialogState(() => _selectedLogoIcon = iconName);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primary.withOpacity(0.2) : AppColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isSel ? AppColors.primary : AppColors.border),
                        ),
                        child: Icon(_getIconData(iconName), color: isSel ? AppColors.primary : Colors.white),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar', style: TextStyle(color: AppColors.subtext)),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = _teamNameController.text.trim();
                  if (name.isNotEmpty) {
                    ref.read(teamsProvider.notifier).createTeam(
                          name,
                          _selectedPrimaryColor,
                          '#171F33',
                          _selectedLogoIcon,
                        );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Cadastrar Time'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openAddPlayerDialog(int teamId, List<String> currentPlayers) {
    final globalPlayers = ref.read(playersProvider);

    final nameCtrl = TextEditingController();
    final shirtCtrl = TextEditingController(text: '${currentPlayers.length + 1}');
    String selectedPosition = 'Atacante';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.border),
            ),
            title: const Row(
              children: [
                Icon(Icons.person_add, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Cadastrar Jogador no Time', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Jogador',
                      hintText: 'Ex: Ninho, Cristiano, Haaland',
                      prefixIcon: Icon(Icons.person, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: shirtCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Número da Camisa',
                      hintText: 'Ex: 10',
                      prefixIcon: Icon(Icons.numbers, color: AppColors.gold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedPosition,
                    decoration: const InputDecoration(
                      labelText: 'Posição do Jogador',
                      prefixIcon: Icon(Icons.sports, color: AppColors.primary),
                    ),
                    dropdownColor: AppColors.cardBackground,
                    items: ['Goleiro', 'Zagueiro', 'Lateral', 'Meio-Campo', 'Atacante', 'Ponta'].map((pos) {
                      return DropdownMenuItem(value: pos, child: Text(pos));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedPosition = val);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar', style: TextStyle(color: AppColors.subtext)),
              ),
              ElevatedButton(
                onPressed: () {
                  final typedName = nameCtrl.text.trim();
                  if (typedName.isNotEmpty) {
                    final shirt = int.tryParse(shirtCtrl.text) ?? (currentPlayers.length + 1);

                    // Auto add to global players if not present
                    if (!globalPlayers.contains(typedName)) {
                      ref.read(playersProvider.notifier).addPlayer(typedName);
                    }

                    ref.read(teamsProvider.notifier).addPlayerToTeam(
                          teamId,
                          typedName,
                          shirtNumber: shirt,
                          position: selectedPosition,
                        );

                    Navigator.pop(ctx);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Digite o nome do jogador!')),
                    );
                  }
                },
                child: const Text('Cadastrar no Elenco'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teams = ref.watch(teamsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('🛡️ Banco de Times & Elencos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield, color: AppColors.primary),
            tooltip: 'Novo Time',
            onPressed: _openCreateTeamDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.shield, color: AppColors.primary, size: 32),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'BANCO DE TIMES & ESTRUTURA TÁTICA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Cadastre as equipes, escolha escudos, cores de uniforme, elenco e atribua Capitão, Goleiro e Cobradores de Faltas/Pênaltis!',
                            style: TextStyle(color: AppColors.subtext, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${teams.length} TIMES CADASTRADOS',
                    style: const TextStyle(
                      color: AppColors.subtext,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _openCreateTeamDialog,
                    icon: const Icon(Icons.add, size: 16, color: Colors.black),
                    label: const Text('Novo Time', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (teams.isEmpty)
                CustomCard(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: const [
                      Icon(Icons.shield_outlined, color: AppColors.subtext, size: 48),
                      SizedBox(height: 12),
                      Text('Nenhum time cadastrado no Banco de Times.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      Text('Clique em "Novo Time" acima para criar a primeira equipe com escudo e cores!', style: TextStyle(color: AppColors.subtext, fontSize: 12)),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: teams.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final t = teams[index];
                    final teamColor = _parseColor(t.primaryColorHex);
                    final teamIcon = _getIconData(t.logoIcon);

                    return CustomCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Escudo + Nome + Delete
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: teamColor.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: teamColor, width: 2),
                                ),
                                child: Center(
                                  child: Icon(teamIcon, color: teamColor, size: 24),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.name.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      '${t.players.length} Jogadores no Elenco',
                                      style: const TextStyle(color: AppColors.subtext, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.subtext),
                                onPressed: () {
                                  ref.read(teamsProvider.notifier).deleteTeam(t.id);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Roles Assignment Grid (Capitão, Goleiro, Pênaltis, Faltas)
                          const Text(
                            'LIDERANÇA & COBRADORES TÁTICOS',
                            style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _RoleDropdownTile(
                                label: '👑 Capitão',
                                value: t.captain,
                                players: t.players,
                                color: AppColors.gold,
                                onChanged: (val) {
                                  ref.read(teamsProvider.notifier).setTeamRole(t.id, 'captain', val);
                                },
                              ),
                              _RoleDropdownTile(
                                label: '🧤 Goleiro',
                                value: t.goalkeeper,
                                players: t.players,
                                color: AppColors.primary,
                                onChanged: (val) {
                                  ref.read(teamsProvider.notifier).setTeamRole(t.id, 'goalkeeper', val);
                                },
                              ),
                              _RoleDropdownTile(
                                label: '🎯 Pênaltis',
                                value: t.penaltyTaker,
                                players: t.players,
                                color: AppColors.secondary,
                                onChanged: (val) {
                                  ref.read(teamsProvider.notifier).setTeamRole(t.id, 'penaltyTaker', val);
                                },
                              ),
                              _RoleDropdownTile(
                                label: '⚽ Faltas',
                                value: t.freeKickTaker,
                                players: t.players,
                                color: AppColors.tertiary,
                                onChanged: (val) {
                                  ref.read(teamsProvider.notifier).setTeamRole(t.id, 'freeKickTaker', val);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Roster List
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'PLANTEL DE JOGADORES',
                                style: TextStyle(color: AppColors.subtext, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              ),
                              InkWell(
                                onTap: () => _openAddPlayerDialog(t.id, t.players),
                                child: const Row(
                                  children: [
                                    Icon(Icons.person_add, color: AppColors.primary, size: 14),
                                    SizedBox(width: 4),
                                    Text('Adicionar Jogador', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          if (t.players.isEmpty)
                            const Text('Nenhum jogador no elenco. Clique em "Adicionar Jogador" acima.', style: TextStyle(color: AppColors.subtext, fontSize: 11))
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: t.players.map((pName) {
                                final shirt = t.shirtNumbers[pName] ?? 10;
                                final pos = t.playerPositions[pName] ?? 'Atacante';

                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceHigh,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.gold.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text('#$shirt', style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(pName, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                          Text(pos, style: const TextStyle(color: AppColors.subtext, fontSize: 9)),
                                        ],
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () {
                                          ref.read(teamsProvider.notifier).removePlayerFromTeam(t.id, pName);
                                        },
                                        child: const Icon(Icons.close, color: AppColors.subtext, size: 14),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleDropdownTile extends StatelessWidget {
  final String label;
  final String value;
  final List<String> players;
  final Color color;
  final ValueChanged<String> onChanged;

  const _RoleDropdownTile({
    required this.label,
    required this.value,
    required this.players,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final validVal = players.contains(value) ? value : null;

    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: validVal,
            isExpanded: true,
            isDense: true,
            underline: const SizedBox(),
            dropdownColor: AppColors.cardBackground,
            hint: const Text('Escolher...', style: TextStyle(color: AppColors.subtext, fontSize: 11)),
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            items: players.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (val) {
              if (val != null) onChanged(val);
            },
          ),
        ],
      ),
    );
  }
}
