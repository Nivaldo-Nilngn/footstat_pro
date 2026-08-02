import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/players_provider.dart';
import '../providers/tournaments_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/primary_button.dart';

class CreateTournamentScreen extends ConsumerStatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  ConsumerState<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends ConsumerState<CreateTournamentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final Set<String> _selectedPlayers = {};

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createTournament() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o nome do torneio!')),
      );
      return;
    }

    if (_selectedPlayers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione ao menos 1 competidor!')),
      );
      return;
    }

    await ref.read(tournamentsProvider.notifier).createTournament(
          name,
          _selectedPlayers.toList(),
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Torneio "$name" criado com sucesso!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final globalPlayers = ref.watch(playersProvider);

    return Scaffold(
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
                      'Nome do Torneio / Temporada',
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
                        hintText: 'Ex: Copa de Verão 2026',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Selecione os Participantes',
                    style: TextStyle(
                      color: AppColors.subtext,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (globalPlayers.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (_selectedPlayers.length == globalPlayers.length) {
                            _selectedPlayers.clear();
                          } else {
                            _selectedPlayers.addAll(globalPlayers);
                          }
                        });
                      },
                      child: Text(
                        _selectedPlayers.length == globalPlayers.length
                            ? 'Desmarcar Todos'
                            : 'Selecionar Todos',
                        style: const TextStyle(color: AppColors.primary),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              Expanded(
                child: globalPlayers.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum competidor cadastrado.\nCadastre competidores na tela de Competidores primeiro.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.subtext),
                        ),
                      )
                    : ListView.separated(
                        itemCount: globalPlayers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final pName = globalPlayers[index];
                          final isSelected = _selectedPlayers.contains(pName);
                          return CustomCard(
                            padding: EdgeInsets.zero,
                            child: CheckboxListTile(
                              activeColor: AppColors.primary,
                              checkColor: Colors.white,
                              title: Text(
                                pName,
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              value: isSelected,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedPlayers.add(pName);
                                  } else {
                                    _selectedPlayers.remove(pName);
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),

              PrimaryButton(
                label: 'Criar Torneio',
                icon: Icons.check,
                onPressed: globalPlayers.isEmpty ? null : _createTournament,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
