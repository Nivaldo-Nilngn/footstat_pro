import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/csv_helper.dart';
import '../providers/tournaments_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/primary_button.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  int? _selectedExportTournamentId;

  void _exportCSV() async {
    if (_selectedExportTournamentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um torneio para exportar!')),
      );
      return;
    }

    final tournaments = ref.read(tournamentsProvider);
    final tList = tournaments.where((item) => item.id == _selectedExportTournamentId).toList();
    if (tList.isEmpty) return;

    final t = tList.first;
    final csvStr = CsvHelper.generateTournamentCsv(t);

    final fileName = 'Backup_${t.name.replaceAll(RegExp(r'\s+'), '_')}.csv';

    try {
      final xFile = XFile.fromData(
        Uint8List.fromList(csvStr.codeUnits),
        mimeType: 'text/csv',
        name: fileName,
      );

      await Share.shareXFiles(
        [xFile],
        text: 'Backup do Torneio ${t.name}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar: $e')),
        );
      }
    }
  }

  void _importCSV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        String content = '';

        if (file.bytes != null) {
          content = String.fromCharCodes(file.bytes!);
        } else if (file.path != null) {
          content = await File(file.path!).readAsString();
        }

        if (content.isNotEmpty) {
          final importedTournament = CsvHelper.parseTournamentCsv(content);
          await ref.read(tournamentsProvider.notifier).importTournament(importedTournament);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Torneio "${importedTournament.name}" importado com sucesso!')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao importar arquivo CSV: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tournaments = ref.watch(tournamentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('💾 Backup (Excel / CSV)'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Export Section
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📥 Exportar Torneio para Excel / CSV',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gera um arquivo de backup com o acumulado de estatísticas de todos os participantes.',
                      style: TextStyle(color: AppColors.subtext, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _selectedExportTournamentId,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      dropdownColor: AppColors.cardBackground,
                      hint: const Text('Selecione um torneio...'),
                      items: tournaments.map((t) {
                        return DropdownMenuItem<int>(
                          value: t.id,
                          child: Text(t.name, style: const TextStyle(color: AppColors.text)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedExportTournamentId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    PrimaryButton(
                      label: 'Exportar Backup CSV',
                      icon: Icons.file_download,
                      onPressed: tournaments.isEmpty ? null : _exportCSV,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Import Section
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📤 Importar Torneio (Excel / CSV)',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Selecione um arquivo de backup CSV para restaurar ou importar torneios no aplicativo.',
                      style: TextStyle(color: AppColors.subtext, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    PrimaryButton(
                      label: 'Importar Arquivo CSV',
                      icon: Icons.file_upload,
                      color: AppColors.cardSecondary,
                      onPressed: _importCSV,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
