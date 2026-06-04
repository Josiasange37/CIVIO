import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/ai_chat_provider.dart';
import '../widgets/animations/animations.dart';
import '../widgets/design_system/duo_choice_card.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _showWelcome = true;
  int _sessionXp = 0;
  bool _showXp = false;

  static const _quickPrompts = [
    ('Comment renouveler ma CNI ?', Icons.badge_outlined),
    ('Documents pour le concours ENS', Icons.school_outlined),
    ('Créer une entreprise au Cameroun', Icons.business_outlined),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _showWelcome = false;
      _sessionXp += 10;
      _showXp = true;
    });
    _controller.clear();
    await context.read<AIChatProvider>().sendMessage(text);
    _scrollToBottom();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showXp = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<AIChatProvider>();
    final progress = chat.messages.isEmpty ? 0.05 : (chat.messages.length / 10).clamp(0.05, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF131F24),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(context, chat, progress),
                Expanded(
                  child: chat.messages.isEmpty && _showWelcome
                      ? _buildWelcome(context, chat)
                      : _buildMessages(context, chat),
                ),
                _buildInput(context, chat),
              ],
            ),
            if (_showXp)
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(child: DuoXpToast(xp: 10, onDone: () => setState(() => _showXp = false))),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AIChatProvider chat, double progress) {
    final modeLabel = switch (chat.mode) {
      ChatMode.online => 'IA en ligne',
      ChatMode.offline => 'Mode hors ligne',
      ChatMode.unavailable => 'Indisponible',
    };
    final modeColor = switch (chat.mode) {
      ChatMode.online => const Color(0xFF58CC02),
      ChatMode.offline => const Color(0xFF1CB0F6),
      ChatMode.unavailable => Colors.orange,
    };

    return Container(
      padding: const EdgeInsets.all(EkemaSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
              const Expanded(
                child: Text(
                  'Chat EKEMA',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: modeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: modeColor, width: 2),
                ),
                child: Text(modeLabel, style: TextStyle(color: modeColor, fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: Color(0xFFFF9600), size: 22),
              const SizedBox(width: 6),
              Text('$_sessionXp XP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              const SizedBox(width: 16),
              Expanded(
                child: DuoProgressBar(
                  value: progress,
                  color: const Color(0xFF58CC02),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome(BuildContext context, AIChatProvider chat) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(EkemaSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StaggerFadeSlide(
            index: 0,
            child: MascotSpeechBubble(
              text: chat.getWelcomeMessage(),
              mascot: DuoMascot(size: 80, mood: chat.isOnline ? 'happy' : 'thinking'),
            ),
          ),
          const SizedBox(height: EkemaSpacing.xxl),
          StaggerFadeSlide(
            index: 1,
            child: const Text(
              'Choisissez une question',
              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: EkemaSpacing.md),
          ...List.generate(_quickPrompts.length, (i) {
            final (prompt, icon) = _quickPrompts[i];
            return StaggerFadeSlide(
              index: i + 2,
              child: DuoChoiceCard(
                title: prompt,
                icon: icon,
                onTap: () => _send(prompt),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMessages(BuildContext context, AIChatProvider chat) {
    if (chat.isLoading) _scrollToBottom();

    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(horizontal: EkemaSpacing.lg, vertical: 8),
      itemCount: chat.messages.length + (chat.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == chat.messages.length && chat.isLoading) {
          return Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16),
            child: Row(
              children: [
                const DuoMascot(size: 48, mood: 'thinking'),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2C33),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF37464F), width: 2),
                  ),
                  child: const TypingDots(),
                ),
              ],
            ),
          );
        }

        final msg = chat.messages[index];
        final isUser = msg['role'] == 'user';
        return StaggerFadeSlide(
          index: index % 5,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isUser) ...[
                  const DuoMascot(size: 44),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF1CB0F6) : const Color(0xFF1F2C33),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isUser ? 18 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 18),
                      ),
                      border: Border.all(
                        color: isUser ? const Color(0xFF1899D6) : const Color(0xFF37464F),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isUser ? const Color(0xFF1899D6) : const Color(0xFF37464F)),
                          blurRadius: 0,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      msg['content'] ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.45,
                        fontWeight: isUser ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInput(BuildContext context, AIChatProvider chat) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1F2C33),
        border: Border(top: BorderSide(color: Color(0xFF37464F), width: 2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Posez votre question…',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                filled: true,
                fillColor: const Color(0xFF131F24),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF37464F), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF37464F), width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF1CB0F6), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onSubmitted: chat.isLoading ? null : _send,
            ),
          ),
          const SizedBox(width: 10),
          BouncyPress(
            onTap: chat.isLoading ? null : () => _send(_controller.text),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF58CC02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF46A302), width: 3),
                boxShadow: const [
                  BoxShadow(color: Color(0xFF46A302), blurRadius: 0, offset: Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
