import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/teams_provider.dart';
import '../providers/tournaments_provider.dart';

class FixtureGeneratorDialog extends ConsumerStatefulWidget {
  final int tournamentId;
  final List<String> tournamentPlayers;
  final bool isIndividualMode;

  const FixtureGeneratorDialog({
    super.key,
    required this.tournamentId,
    required this.tournamentPlayers,
    required this.isIndividualMode,
  });

  @override
  ConsumerState<FixtureGeneratorDialog> createState() => _FixtureGeneratorDialogState();
}

class _FixtureGeneratorDialogState extends ConsumerState<FixtureGeneratorDialog> {
  final TextEditingController _locationController = TextEditingController(text: 'Campo Principal - Arena 1');
  final TextEditingController _dateController = TextEditingController(text: '15/08/2026');
  final TextEditingController _startTimeController = TextEditingController(text: '19:00');
  
  final TextEditingController _teamANameController = TextEditingController(text: 'Time Sem Camisa');
  final TextEditingController _teamBNameController = TextEditingController(text: 'Time Com Camisa');

  bool _isSpinning = false;
  String _rouletteText = 'Toque em "GIRAR ROLETA" para sortear as chaves!';

  @override
  void dispose() {
    _locationController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _teamANameController.dispose();
    _teamBNameController.dispose();
    super.dispose();
  }

  void _runRouletteSpin() async {
    final teams = ref.read(teamsProvider);
    final allChoices = <String>{};
    if (!widget.isIndividualMode) {
      for (var t in teams) {
        allChoices.add(t.name);
      }
    }
    for (var p in widget.tournamentPlayers) {
      allChoices.add(p);
    }
    
    final choicesList = allChoices.toList();

    if (choicesList.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('É necessário ter ao menos 2 participantes (times ou jogadores) para o sorteio!')),
      );
      return;
    }

    setState(() {
      _isSpinning = true;
    });

    final rand = Random();
    for (int i = 0; i < 15; i++) {
      await Future.delayed(Duration(milliseconds: 100 + i * 20));
      if (!mounted) return;
      final t1 = choicesList[rand.nextInt(choicesList.length)];
      final t2 = choicesList[rand.nextInt(choicesList.length)];
      setState(() {
        _rouletteText = '🎰 $t1  ⚡ VS ⚡  $t2';
      });
    }

    // Generate round robin matches
    final location = _locationController.text.trim();
    final date = _dateController.text.trim();
    int baseHour = 19;
    int baseMinute = 0;

    int matchCount = 0;
    
    if (widget.isIndividualMode) {
      // Pick-up game mode (Pelada): Divide players into 2 teams
      final teamAName = _teamANameController.text.trim().isNotEmpty ? _teamANameController.text.trim() : 'Time A';
      final teamBName = _teamBNameController.text.trim().isNotEmpty ? _teamBNameController.text.trim() : 'Time B';
      
      final half = choicesList.length ~/ 2;
      final rosterA = choicesList.sublist(0, half);
      final rosterB = choicesList.sublist(half);
      
      final matchTime = '${baseHour.toString().padLeft(2, "0")}:${baseMinute.toString().padLeft(2, "0")}';

      await ref.read(tournamentsProvider.notifier).addScheduledMatch(
            tournamentId: widget.tournamentId,
            teamAName: teamAName,
            teamBName: teamBName,
            teamAPlayers: rosterA,
            teamBPlayers: rosterB,
            matchDate: date,
            matchTime: matchTime,
            location: location,
          );
      matchCount++;
      
    } else {
      // Teams mode: Round Robin
      for (int i = 0; i < choicesList.length; i++) {
        for (int j = i + 1; j < choicesList.length; j++) {
          final tA = choicesList[i];
          final tB = choicesList[j];

          List<String> rosterA = [tA];
          try {
            final teamAObj = teams.firstWhere((t) => t.name == tA);
            rosterA = teamAObj.players;
          } catch (_) {}
          
          List<String> rosterB = [tB];
          try {
            final teamBObj = teams.firstWhere((t) => t.name == tB);
            rosterB = teamBObj.players;
          } catch (_) {}

          final matchTime = '${baseHour.toString().padLeft(2, "0")}:${baseMinute.toString().padLeft(2, "0")}';

          await ref.read(tournamentsProvider.notifier).addScheduledMatch(
                tournamentId: widget.tournamentId,
                teamAName: tA,
                teamBName: tB,
                teamAPlayers: rosterA,
                teamBPlayers: rosterB,
                matchDate: date,
                matchTime: matchTime,
                location: location,
              );

          matchCount++;
          baseMinute += 40;
          if (baseMinute >= 60) {
            baseHour += 1;
            baseMinute -= 60;
          }
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _isSpinning = false;
      _rouletteText = '🎉 $matchCount partidas sorteadas e agendadas com sucesso!';
    });

    await Future.delayed(const Duration(seconds: 1));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final teams = ref.watch(teamsProvider);
    
    final allChoices = <String>{};
    if (!widget.isIndividualMode) {
      for (var t in teams) {
        allChoices.add(t.name);
      }
    }
    for (var p in widget.tournamentPlayers) {
      allChoices.add(p);
    }
    
    final choicesList = allChoices.toList();
    final modeLabel = widget.isIndividualMode ? 'jogadores' : 'participantes (times/jogadores)';

    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      title: const Row(
        children: [
          Icon(Icons.casino, color: AppColors.gold, size: 28),
          SizedBox(width: 10),
          Text('Roleta & Sorteio de Jogos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Encontrados ${choicesList.length} $modeLabel cadastrados para o sorteio automático:',
            style: const TextStyle(color: AppColors.subtext, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: choicesList.map((c) => Chip(
              backgroundColor: AppColors.surfaceHigh,
              avatar: Icon(widget.isIndividualMode ? Icons.person : Icons.shield, color: AppColors.primary, size: 14),
              label: Text(c, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            )).toList(),
          ),
          const SizedBox(height: 16),

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
                  controller: _startTimeController,
                  decoration: const InputDecoration(labelText: 'Horário Inicial'),
                ),
              ),
            ],
          ),
          if (widget.isIndividualMode) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _teamANameController,
                    decoration: const InputDecoration(labelText: 'Nome do Time 1'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _teamBNameController,
                    decoration: const InputDecoration(labelText: 'Nome do Time 2'),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),

          // Animated Wheel Box
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gold.withOpacity(0.4)),
            ),
            child: Text(
              _rouletteText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _isSpinning ? AppColors.gold : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSpinning ? null : () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: AppColors.subtext)),
        ),
        ElevatedButton.icon(
          onPressed: _isSpinning ? null : _runRouletteSpin,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
          icon: const Icon(Icons.casino, color: Colors.black, size: 18),
          label: const Text('GIRAR ROLETA & AGENDAR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
