import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/teams_provider.dart';
import '../providers/tournaments_provider.dart';

class ManualMatchScheduleDialog extends ConsumerStatefulWidget {
  final int tournamentId;

  const ManualMatchScheduleDialog({super.key, required this.tournamentId});

  @override
  ConsumerState<ManualMatchScheduleDialog> createState() => _ManualMatchScheduleDialogState();
}

class _ManualMatchScheduleDialogState extends ConsumerState<ManualMatchScheduleDialog> {
  String? _teamA;
  String? _teamB;
  final TextEditingController _locationController = TextEditingController(text: 'Campo 1 - Arena Principal');
  final TextEditingController _dateController = TextEditingController(text: '15/08/2026');
  final TextEditingController _timeController = TextEditingController(text: '19:30');

  @override
  void dispose() {
    _locationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _scheduleMatch() async {
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

    final teams = ref.read(teamsProvider);
    final teamAObj = teams.firstWhere((t) => t.name == _teamA);
    final teamBObj = teams.firstWhere((t) => t.name == _teamB);

    await ref.read(tournamentsProvider.notifier).addScheduledMatch(
          tournamentId: widget.tournamentId,
          teamAName: teamAObj.name,
          teamBName: teamBObj.name,
          teamAPlayers: teamAObj.players,
          teamBPlayers: teamBObj.players,
          matchDate: _dateController.text.trim(),
          matchTime: _timeController.text.trim(),
          location: _locationController.text.trim(),
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Confronto "${teamAObj.name} vs ${teamBObj.name}" agendado!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final teams = ref.watch(teamsProvider);

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
          Text('Agendar Confronto Manual', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TIME A (MANDANTE)', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: _teamA,
              decoration: const InputDecoration(hintText: 'Selecione o Time A'),
              dropdownColor: AppColors.cardBackground,
              items: teams.map((t) => DropdownMenuItem(value: t.name, child: Text(t.name))).toList(),
              onChanged: (val) => setState(() => _teamA = val),
            ),
            const SizedBox(height: 14),

            const Text('TIME B (VISITANTE)', style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: _teamB,
              decoration: const InputDecoration(hintText: 'Selecione o Time B'),
              dropdownColor: AppColors.cardBackground,
              items: teams.map((t) => DropdownMenuItem(value: t.name, child: Text(t.name))).toList(),
              onChanged: (val) => setState(() => _teamB = val),
            ),
            const SizedBox(height: 14),

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
