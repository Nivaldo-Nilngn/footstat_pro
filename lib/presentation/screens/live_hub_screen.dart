import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class LiveHubScreen extends StatefulWidget {
  final Map<String, dynamic> liveData;

  const LiveHubScreen({super.key, required this.liveData});

  @override
  State<LiveHubScreen> createState() => _LiveHubScreenState();
}

class _LiveHubScreenState extends State<LiveHubScreen> {
  final List<Map<String, String>> _chatMessages = [];
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String? _votedMvp;
  int _viewers = 1205;

  @override
  void initState() {
    super.initState();
    _generateMockChat();
    _startViewerSimulation();

    final url = widget.liveData['liveUrl'] as String? ?? '';
    
    // Convert standard youtube link to embed link
    String embedUrl = url;
    if (url.contains('youtube.com/watch?v=')) {
      final videoId = url.split('v=')[1].split('&')[0];
      embedUrl = 'https://www.youtube.com/embed/$videoId?autoplay=1';
    } else if (url.contains('youtu.be/')) {
      final videoId = url.split('youtu.be/')[1].split('?')[0];
      embedUrl = 'https://www.youtube.com/embed/$videoId?autoplay=1';
    }

    // Register iframe view factory
    // Use a unique id for the iframe based on the URL to avoid conflicts
    final viewId = 'iframe-player-$embedUrl';
    try {
      ui_web.platformViewRegistry.registerViewFactory(
        viewId,
        (int viewId) => html.IFrameElement()
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allowFullscreen = true
          ..src = embedUrl,
      );
    } catch (e) {
      // Ignore if already registered
    }
  }

  void _generateMockChat() {
    final names = ['ProGamer99', 'FallenFan', 'K1ng', 'MVP_Hunter', 'NinjaBr', 'FutebolArte'];
    final messages = [
      'Que jogada incrível! 🔥',
      'GGWP',
      'Vamo timeee',
      'Esse cara joga muito',
      'Alguém sabe o nível dele?',
      'Defesaça!',
    ];
    
    for (int i = 0; i < 8; i++) {
      _chatMessages.add({
        'user': names[Random().nextInt(names.length)],
        'message': messages[Random().nextInt(messages.length)],
      });
    }
  }

  void _startViewerSimulation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _viewers += Random().nextInt(15) - 5;
          _chatMessages.add({
            'user': 'FootStatBot',
            'message': 'Bem-vindo ao chat ao vivo! Não esqueça de votar no MVP da partida.',
          });
        });
        _scrollToBottom();
      }
    });
  }

  void _sendMessage() {
    if (_chatController.text.trim().isEmpty) return;
    setState(() {
      _chatMessages.add({
        'user': 'Você',
        'message': _chatController.text.trim(),
      });
    });
    _chatController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _openLiveUrl() async {
    // Agora o vídeo roda direto na tela (iframe), esse botão pode ser removido
    // ou apenas exibir uma mensagem se a URL for inválida.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${widget.liveData['tournamentName']} - Ao Vivo'),
        backgroundColor: AppColors.cardBackground,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 800;

          if (isDesktop) {
            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildVideoAndDetails(),
                ),
                Container(width: 1, color: AppColors.border),
                Expanded(
                  flex: 1,
                  child: _buildChatPanel(),
                ),
              ],
            );
          }

          return Column(
            children: [
              _buildVideoAndDetails(),
              const Divider(color: AppColors.border, height: 1),
              Expanded(child: _buildChatPanel()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVideoAndDetails() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Player Iframe
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  HtmlElementView(
                    viewType: (() {
                      final url = widget.liveData['liveUrl'] as String? ?? '';
                      String embedUrl = url;
                      if (url.contains('youtube.com/watch?v=')) {
                        final videoId = url.split('v=')[1].split('&')[0];
                        embedUrl = 'https://www.youtube.com/embed/$videoId?autoplay=1';
                      } else if (url.contains('youtu.be/')) {
                        final videoId = url.split('youtu.be/')[1].split('?')[0];
                        embedUrl = 'https://www.youtube.com/embed/$videoId?autoplay=1';
                      }
                      return 'iframe-player-$embedUrl';
                    })(),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 10),
                          SizedBox(width: 6),
                          Text('AO VIVO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.remove_red_eye, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text('$_viewers', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.liveData['activityName'] ?? 'Partida',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.liveData['tournamentName'] ?? 'Torneio Oficial',
                  style: const TextStyle(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                
                // MVP Voting Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber),
                          SizedBox(width: 8),
                          Text(
                            'Vote no MVP da Partida',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Builder(
                        builder: (context) {
                          final playersList = widget.liveData['players'] as List<String>? ?? [];
                          final displayPlayers = playersList.isNotEmpty ? playersList : ['Jogador 1', 'Jogador 2'];
                          
                          return Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: displayPlayers.map((player) {
                              final isSelected = _votedMvp == player;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _votedMvp = player;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Você votou em $player para MVP!')),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.cardBackground,
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : AppColors.border,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.person, size: 16, color: isSelected ? AppColors.primary : Colors.white70),
                                      const SizedBox(width: 8),
                                      Text(
                                        player,
                                        style: TextStyle(
                                          color: isSelected ? AppColors.primary : Colors.white,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatPanel() {
    return Container(
      color: AppColors.cardBackground,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: const Row(
              children: [
                Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text('Chat ao Vivo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final msg = _chatMessages[index];
                final isMe = msg['user'] == 'Você';
                final isBot = msg['user'] == 'FootStatBot';
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMe) ...[
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: isBot ? AppColors.primary : AppColors.surfaceHigh,
                          child: Text(
                            msg['user']![0].toUpperCase(),
                            style: TextStyle(fontSize: 10, color: isBot ? Colors.black : Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Text(
                                msg['user']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isBot ? AppColors.primary : AppColors.subtext,
                                ),
                              ),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isMe ? AppColors.primary.withOpacity(0.2) : AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isMe ? AppColors.primary.withOpacity(0.5) : AppColors.border),
                              ),
                              child: Text(
                                msg['message']!,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 8),
                        const CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.person, size: 14, color: Colors.black),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Enviar mensagem...',
                      hintStyle: const TextStyle(color: AppColors.subtext),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.black, size: 18),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
