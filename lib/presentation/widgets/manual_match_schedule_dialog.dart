import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/teams_provider.dart';
import '../providers/tournaments_provider.dart';

class ManualMatchScheduleDialog extends ConsumerStatefulWidget {
  final int tournamentId;
  final List<String> tournamentPlayers;
  final bool isIndividualMode;

  const ManualMatchScheduleDialog({
    super.key,
    required this.tournamentId,
    required this.tournamentPlayers,
    required this.isIndividualMode,
  });

  @override
  ConsumerState<ManualMatchScheduleDialog> createState() => _ManualMatchScheduleDialogState();
}

class _ManualMatchScheduleDialogState extends ConsumerState<ManualMatchScheduleDialog> {
  // Para Modo Times
  String? _teamA;
  String? _teamB;

  // Para Modo Pelada (Jogadores Avulsos)
  final TextEditingController _teamANameController = TextEditingController(text: 'Time Sem Camisa');
  final TextEditingController _teamBNameController = TextEditingController(text: 'Time Com Camisa');
  final List<String> _selectedPlayersA = [];
  final List<String> _selectedPlayersB = [];

  final TextEditingController _locationController = TextEditingController(text: 'Campo 1 - Arena Principal');
  final TextEditingController _dateController = TextEditingController(text: '15/08/2026');
  final TextEditingController _timeController = TextEditingController(text: '19:30');

  @override
  void dispose() {
    _locationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _teamANameController.dispose();
    _teamBNameController.dispose();
    super.dispose();
  }

  void _scheduleMatch() async {
    final teams = ref.read(teamsProvider);
    String finalTeamAName = '';
    String finalTeamBName = '';
    List<String> rosterA = [];
    List<String> rosterB = [];

    if (widget.isIndividualMode) {
      if (_selectedPlayersA.isEmpty || _selectedPlayersB.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione pelo menos 1 jogador para cada time!')),
        );
        return;
      }
      finalTeamAName = _teamANameController.text.trim().isNotEmpty ? _teamANameController.text.trim() : 'Time A';
      finalTeamBName = _teamBNameController.text.trim().isNotEmpty ? _teamBNameController.text.trim() : 'Time B';
      rosterA = List.from(_selectedPlayersA);
      rosterB = List.from(_selectedPlayersB);
    } else {
      if (_teamA == null || _teamB == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione os 2 times que irão disputar a partida!')),
        );
        return;
      }
      if (_teamA == _teamB) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione times diferentes para o confronto!')),
        );
        return;
      }
      
      finalTeamAName = _teamA!;
      finalTeamBName = _teamB!;
      
      rosterA = [_teamA!];
      try {
        final teamAObj = teams.firstWhere((t) => t.name == _teamA);
        rosterA = teamAObj.players;
      } catch (_) {}
      
      rosterB = [_teamB!];
      try {
        final teamBObj = teams.firstWhere((t) => t.name == _teamB);
        rosterB = teamBObj.players;
      } catch (_) {}
    }

    await ref.read(tournamentsProvider.notifier).addScheduledMatch(
          tournamentId: widget.tournamentId,
          teamAName: finalTeamAName,
          teamBName: finalTeamBName,
          teamAPlayers: rosterA,
          teamBPlayers: rosterB,
          matchDate: _dateController.text.trim(),
          matchTime: _timeController.text.trim(),
          location: _locationController.text.trim(),
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Confronto "$finalTeamAName vs $finalTeamBName" agendado!')),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildPlayerSelectionChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        TextField(
          controller: _teamANameController,
          decoration: const InputDecoration(labelText: 'Nome do Time 1'),
        ),
        const SizedBox(height: 8),
        const Text('Selecione os jogadores do Time 1:', style: TextStyle(color: AppColors.subtext, fontSize: 11)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          children: widget.tournamentPlayers.map((p) {
            final isSelected = _selectedPlayersA.contains(p);
            final isDisabled = _selectedPlayersB.contains(p);
            return FilterChip(
              label: Text(p, style: const TextStyle(fontSize: 11)),
              selected: isSelected,
              onSelected: isDisabled ? null : (selected) {
                setState(() {
                  if (selected) {
                    _selectedPlayersA.add(p);
                  } else {
                    _selectedPlayersA.remove(p);
                  }
                });
              },
              backgroundColor: AppColors.surfaceHigh,
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.black,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : (isDisabled ? Colors.white38 : Colors.white),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _teamBNameController,
          decoration: const InputDecoration(labelText: 'Nome do Time 2'),
        ),
        const SizedBox(height: 8),
        const Text('Selecione os jogadores do Time 2:', style: TextStyle(color: AppColors.subtext, fontSize: 11)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          children: widget.tournamentPlayers.map((p) {
            final isSelected = _selectedPlayersB.contains(p);
            final isDisabled = _selectedPlayersA.contains(p);
            return FilterChip(
              label: Text(p, style: const TextStyle(fontSize: 11)),
              selected: isSelected,
              onSelected: isDisabled ? null : (selected) {
                setState(() {
                  if (selected) {
                    _selectedPlayersB.add(p);
                  } else {
                    _selectedPlayersB.remove(p);
                  }
                });
              },
              backgroundColor: AppColors.surfaceHigh,
              selectedColor: AppColors.secondary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : (isDisabled ? Colors.white38 : Colors.white),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildTeamDropdowns() {
    final teams = ref.watch(teamsProvider);
    final allChoices = <String>{};
    for (var t in teams) {
      allChoices.add(t.name);
    }
    final dropdownItems = allChoices.map((choice) => DropdownMenuItem(value: choice, child: Text(choice))).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('TIME A (MANDANTE)', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: _teamA,
          decoration: const InputDecoration(hintText: 'Selecione o Time A'),
          dropdownColor: AppColors.cardBackground,
          items: dropdownItems,
          onChanged: (val) => setState(() => _teamA = val),
        ),
        const SizedBox(height: 14),

        const Text('TIME B (VISITANTE)', style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: _teamB,
          decoration: const InputDecoration(hintText: 'Selecione o Time B'),
          dropdownColor: AppColors.cardBackground,
          items: dropdownItems,
          onChanged: (val) => setState(() => _teamB = val),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      title: const Row(
        children: [
          Icon(Icons.calendar_month, color: AppColors.primary),
          SizedBox(width: 10),
          Text('Agendar Confronto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isIndividualMode)
              _buildPlayerSelectionChips()
            else
              _buildTeamDropdowns(),
              
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Local do Jogo / Campo'),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(labelText: 'Data do Jogo'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _timeController,
                    decoration: const InputDecoration(labelText: 'Horário (HH:mm)'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: AppColors.subtext)),
        ),
        ElevatedButton.icon(
          onPressed: _scheduleMatch,
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Salvar Confronto'),
        ),
      ],
    );
  }
}
