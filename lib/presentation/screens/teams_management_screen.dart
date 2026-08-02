import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
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
  final Set<int> _expandedTeams = {};
  bool _allExpanded = false;

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }

  void _toggleExpandAll(List teams) {
    setState(() {
      _allExpanded = !_allExpanded;
      if (_allExpanded) {
        for (final t in teams) {
          _expandedTeams.add(t.id);
        }
      } else {
        _expandedTeams.clear();
      }
    });
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
      case 'diamond':
        return Icons.diamond;
      case 'pets':
        return Icons.pets;
      case 'whatshot':
        return Icons.whatshot;
      case 'shield':
      default:
        return Icons.shield;
    }
  }

  void _openCreateTeamDialog() {
    _teamNameController.clear();
    final stadiumCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final yearCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedSecondary = '#171F33';
    String? uploadedLogoBase64;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> pickLogo() async {
            try {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.image,
                allowMultiple: false,
              );
              if (result != null && result.files.isNotEmpty) {
                final bytes = result.files.first.bytes;
                if (bytes != null) {
                  setDialogState(() {
                    uploadedLogoBase64 = base64Encode(bytes);
                  });
                }
              }
            } catch (_) {}
          }

          return Dialog(
            backgroundColor: Colors.transparent,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 440,
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header with gradient accent
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        border: Border(bottom: BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.shield, color: Colors.black, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Criar Novo Time',
                                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  'Preencha os dados da equipe',
                                  style: TextStyle(color: AppColors.subtext, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceHigh,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.close, color: AppColors.subtext, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Logo Upload Area
                            Center(
                              child: GestureDetector(
                                onTap: pickLogo,
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceHigh,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: uploadedLogoBase64 != null
                                          ? AppColors.primary
                                          : AppColors.border,
                                      width: uploadedLogoBase64 != null ? 3 : 2,
                                    ),
                                  ),
                                  child: uploadedLogoBase64 != null
                                      ? ClipOval(
                                          child: Image.memory(
                                            base64Decode(uploadedLogoBase64!),
                                            fit: BoxFit.cover,
                                            width: 90,
                                            height: 90,
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.camera_alt, color: AppColors.subtext, size: 22),
                                            SizedBox(height: 2),
                                            Text('Logo', style: TextStyle(color: AppColors.subtext, fontSize: 9)),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Center(
                              child: Text(
                                uploadedLogoBase64 != null ? 'Toque para trocar' : 'Toque para enviar escudo',
                                style: TextStyle(
                                  color: uploadedLogoBase64 != null ? AppColors.primary : AppColors.subtext,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Identity Section
                            _SectionTitle('IDENTIDADE'),
                            const SizedBox(height: 10),
                            _DialogTextField(
                              controller: _teamNameController,
                              label: 'Nome do Time',
                              hint: 'Ex: Tigres FC',
                              icon: Icons.badge,
                              iconColor: AppColors.primary,
                            ),
                            const SizedBox(height: 10),
                            _DialogTextField(
                              controller: stadiumCtrl,
                              label: 'Estádio / Arena',
                              hint: 'Ex: Arena Tigres',
                              icon: Icons.stadium,
                              iconColor: AppColors.tertiary,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _DialogTextField(
                                    controller: cityCtrl,
                                    label: 'Cidade',
                                    hint: 'São Paulo',
                                    icon: Icons.location_city,
                                    iconColor: AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _DialogTextField(
                                    controller: yearCtrl,
                                    label: 'Fundado em',
                                    hint: '2020',
                                    icon: Icons.calendar_today,
                                    iconColor: AppColors.gold,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _DialogTextField(
                              controller: descCtrl,
                              label: 'Descrição (opcional)',
                              hint: 'Sobre o time...',
                              maxLines: 2,
                            ),
                            const SizedBox(height: 20),

                            // Visual Section
                            _SectionTitle('CORES'),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _ColorPickerRow(
                                    label: 'Principal',
                                    colors: ['#FF4D4D', '#3B82F6', '#4EDEA3', '#A855F7', '#FFD700', '#FF9800'],
                                    selected: _selectedPrimaryColor,
                                    onSelect: (hex) => setDialogState(() => _selectedPrimaryColor = hex),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _ColorPickerRow(
                                    label: 'Secundária',
                                    colors: ['#171F33', '#1A1A2E', '#0D1117', '#2D1B69', '#1B2838', '#0F0F0F'],
                                    selected: selectedSecondary,
                                    onSelect: (hex) => setDialogState(() => selectedSecondary = hex),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Icon Section
                            _SectionTitle('ÍCONE DO ESCUDO'),
                            const SizedBox(height: 10),
                            Row(
                              children: ['shield', 'sports_soccer', 'bolt', 'local_fire_department', 'star', 'diamond', 'pets', 'whatshot'].map((iconName) {
                                final isSel = _selectedLogoIcon == iconName;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setDialogState(() => _selectedLogoIcon = iconName),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isSel ? AppColors.primary.withOpacity(0.2) : AppColors.surfaceHigh,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSel ? AppColors.primary : AppColors.border,
                                          width: isSel ? 2 : 1,
                                        ),
                                      ),
                                      child: Icon(
                                        _getIconData(iconName),
                                        color: isSel ? AppColors.primary : Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),

                            // Preview
                            _SectionTitle('PRÉ-VISUALIZAÇÃO'),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceHigh,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: _parseColor(_selectedPrimaryColor).withOpacity(0.15),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: _parseColor(_selectedPrimaryColor), width: 2),
                                    ),
                                    child: ClipOval(
                                      child: uploadedLogoBase64 != null
                                          ? Image.memory(base64Decode(uploadedLogoBase64!), fit: BoxFit.cover)
                                          : Icon(_getIconData(_selectedLogoIcon), color: _parseColor(_selectedPrimaryColor), size: 24),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _teamNameController.text.isEmpty ? 'NOME DO TIME' : _teamNameController.text.toUpperCase(),
                                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          [cityCtrl.text, stadiumCtrl.text].where((e) => e.isNotEmpty).join(' • ').isEmpty
                                              ? 'Cidade • Estádio'
                                              : [cityCtrl.text, stadiumCtrl.text].where((e) => e.isNotEmpty).join(' • '),
                                          style: const TextStyle(color: AppColors.subtext, fontSize: 10),
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
                    ),

                    // Footer buttons
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: AppColors.border),
                                ),
                              ),
                              child: const Text('Cancelar', style: TextStyle(color: AppColors.subtext)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final name = _teamNameController.text.trim();
                                if (name.isNotEmpty) {
                                  ref.read(teamsProvider.notifier).createTeam(
                                    name,
                                    primaryColorHex: _selectedPrimaryColor,
                                    secondaryColorHex: selectedSecondary,
                                    logoIcon: _selectedLogoIcon,
                                    logoBase64: uploadedLogoBase64 ?? '',
                                    stadium: stadiumCtrl.text.trim(),
                                    city: cityCtrl.text.trim(),
                                    foundedYear: yearCtrl.text.trim(),
                                    description: descCtrl.text.trim(),
                                  );
                                  Navigator.pop(ctx);
                                }
                              },
                              icon: const Icon(Icons.check, color: Colors.black, size: 18),
                              label: const Text('Cadastrar Time'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.shield, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'BANCO DE TIMES & ESTRUTURA TÁTICA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Cadastre equipes, escolha escudos, cores, elenco e atribua funções!',
                            style: TextStyle(color: AppColors.subtext, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Text(
                    '${teams.length} TIMES',
                    style: const TextStyle(
                      color: AppColors.subtext,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  if (teams.isNotEmpty)
                    IconButton(
                      onPressed: () => _toggleExpandAll(teams),
                      icon: Icon(
                        _allExpanded ? Icons.unfold_less : Icons.unfold_more,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      tooltip: _allExpanded ? 'Recolher todos' : 'Expandir todos',
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                  const SizedBox(width: 4),
                  ElevatedButton.icon(
                    onPressed: _openCreateTeamDialog,
                    icon: const Icon(Icons.add, size: 14, color: Colors.black),
                    label: const Text('Novo Time', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

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
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final t = teams[index];
                    final teamColor = _parseColor(t.primaryColorHex);
                    final teamIcon = _getIconData(t.logoIcon);
                    final isExpanded = _expandedTeams.contains(t.id);

                    return CustomCard(
                      padding: EdgeInsets.all(isExpanded ? 16 : 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Compact Header (always visible)
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (_expandedTeams.contains(t.id)) {
                                  _expandedTeams.remove(t.id);
                                } else {
                                  _expandedTeams.add(t.id);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Row(
                              children: [
                                Container(
                                  width: isExpanded ? 40 : 36,
                                  height: isExpanded ? 40 : 36,
                                  decoration: BoxDecoration(
                                    color: teamColor.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: teamColor, width: 2),
                                  ),
                                  child: ClipOval(
                                  child: t.hasCustomLogo
                                      ? Image.memory(base64Decode(t.logoBase64), fit: BoxFit.cover, width: isExpanded ? 40 : 36, height: isExpanded ? 40 : 36)
                                      : Icon(teamIcon, color: teamColor, size: isExpanded ? 20 : 18),
                                ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.name.toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isExpanded ? 15 : 13,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Text(
                                        t.city.isNotEmpty ? '${t.city} • ${t.players.length} jogadores' : '${t.players.length} jogadores',
                                        style: const TextStyle(color: AppColors.subtext, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                                // Role badges (compact view when collapsed)
                                if (!isExpanded) ...[
                                  if (t.captain.isNotEmpty)
                                    _RoleBadge(label: 'C', color: AppColors.gold),
                                  if (t.goalkeeper.isNotEmpty)
                                    _RoleBadge(label: 'G', color: AppColors.primary),
                                  if (t.penaltyTaker.isNotEmpty)
                                    _RoleBadge(label: 'P', color: AppColors.secondary),
                                  if (t.freeKickTaker.isNotEmpty)
                                    _RoleBadge(label: 'F', color: AppColors.tertiary),
                                  const SizedBox(width: 4),
                                ],
                                // Delete
                                InkWell(
                                  onTap: () {
                                    ref.read(teamsProvider.notifier).deleteTeam(t.id);
                                  },
                                  child: const Icon(Icons.delete_outline, color: AppColors.subtext, size: 18),
                                ),
                                const SizedBox(width: 4),
                                AnimatedRotation(
                                  turns: isExpanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: const Icon(Icons.expand_more, color: AppColors.subtext, size: 20),
                                ),
                              ],
                            ),
                          ),

                          // Expanded content
                          AnimatedSize(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            child: isExpanded
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Divider(color: AppColors.border, height: 1),
                                        const SizedBox(height: 12),

                                        // Team Info
                                        if (t.city.isNotEmpty || t.stadium.isNotEmpty || t.foundedYear.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            margin: const EdgeInsets.only(bottom: 12),
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceHigh,
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: AppColors.border),
                                            ),
                                            child: Row(
                                              children: [
                                                if (t.city.isNotEmpty) ...[
                                                  const Icon(Icons.location_on, color: AppColors.secondary, size: 14),
                                                  const SizedBox(width: 4),
                                                  Text(t.city, style: const TextStyle(color: Colors.white, fontSize: 11)),
                                                  const SizedBox(width: 12),
                                                ],
                                                if (t.stadium.isNotEmpty) ...[
                                                  const Icon(Icons.stadium, color: AppColors.tertiary, size: 14),
                                                  const SizedBox(width: 4),
                                                  Text(t.stadium, style: const TextStyle(color: Colors.white, fontSize: 11)),
                                                  const SizedBox(width: 12),
                                                ],
                                                if (t.foundedYear.isNotEmpty) ...[
                                                  const Icon(Icons.calendar_today, color: AppColors.gold, size: 12),
                                                  const SizedBox(width: 4),
                                                  Text(t.foundedYear, style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold)),
                                                ],
                                              ],
                                            ),
                                          ),

                                        // Roles Assignment
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
                                        const SizedBox(height: 14),

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
                                          const Text('Nenhum jogador no elenco.', style: TextStyle(color: AppColors.subtext, fontSize: 11))
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
                                  )
                                : const SizedBox.shrink(),
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.gold,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final Color? iconColor;
  final int maxLines;
  final TextInputType? keyboardType;

  const _DialogTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.icon,
    this.iconColor,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.subtext, fontSize: 12),
        labelStyle: const TextStyle(color: AppColors.subtext, fontSize: 12),
        prefixIcon: icon != null ? Icon(icon, color: iconColor ?? AppColors.subtext, size: 18) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: AppColors.surfaceHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _ColorPickerRow extends StatelessWidget {
  final String label;
  final List<String> colors;
  final String selected;
  final ValueChanged<String> onSelect;

  const _ColorPickerRow({
    required this.label,
    required this.colors,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.subtext, fontSize: 10)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: colors.map((hex) {
            final isSel = selected == hex;
            return GestureDetector(
              onTap: () => onSelect(hex),
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: _parseColorStatic(hex),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSel ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSel
                      ? [BoxShadow(color: _parseColorStatic(hex).withOpacity(0.5), blurRadius: 6)]
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _parseColorStatic(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }
}

class _RoleBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _RoleBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(left: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
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
