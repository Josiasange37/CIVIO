import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/procedure_provider.dart';
import '../providers/voice_provider.dart';
import '../widgets/animations/animations.dart';
import '../widgets/design_system/duo_choice_card.dart';

class DialogueScreen extends StatefulWidget {
  const DialogueScreen({super.key});

  @override
  State<DialogueScreen> createState() => _DialogueScreenState();
}

class _DialogueScreenState extends State<DialogueScreen> {
  final ScrollController _scrollController = ScrollController();
  int _xp = 0;
  bool _showXp = false;

  IconData _iconForOption(String option) {
    final lower = option.toLowerCase();
    if (lower.contains('première') || lower.contains('premiere')) return Icons.person_add_alt_1_outlined;
    if (lower.contains('renouvel')) return Icons.autorenew_rounded;
    if (lower.contains('oui')) return Icons.check_circle_outline;
    if (lower.contains('non')) return Icons.cancel_outlined;
    if (lower.contains('perte') || lower.contains('vol')) return Icons.report_outlined;
    return Icons.touch_app_outlined;
  }

  String? _subtitleForOption(String option) {
    final lower = option.toLowerCase();
    if (lower.contains('première') || lower.contains('premiere')) return 'Première carte d\'identité';
    if (lower.contains('renouvel')) return 'Carte expirée ou perdue';
    if (lower.contains('oui') && lower.contains('fiche')) return 'Pré-enrôlement terminé sur idcam.cm';
    if (lower.contains('non')) return 'On va vous guider étape par étape';
    if (lower.contains('perte')) return 'Déclaration de perte requise';
    return 'Choisissez pour continuer';
  }

  void _onAnswer(BuildContext context, ProcedureProvider provider, String choice) {
    provider.answerQuestion(choice);
    setState(() {
      _xp += 15;
      _showXp = true;
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => _showXp = false);
      if (provider.state == ChatState.completed) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!context.mounted) return;
          Navigator.pushNamed(context, '/result');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProcedureProvider>();
    final procedure = provider.selectedProcedure;

    if (procedure == null) {
      return const Scaffold(body: Center(child: Text('Aucune procédure sélectionnée.')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF131F24),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildLessonHeader(context, procedure, provider),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(EkemaSpacing.lg),
                    itemCount: provider.currentQuestionIndex + 1,
                    itemBuilder: (context, index) {
                      final question = procedure.questions[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          StaggerFadeSlide(
                            index: 0,
                            child: MascotSpeechBubble(
                              text: question.text,
                              mascot: DuoMascot(
                                size: 72,
                                mood: index == provider.currentQuestionIndex ? 'happy' : 'thinking',
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          StaggerFadeSlide(
                            index: 1,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () => context.read<VoiceProvider>().speak(question.text),
                                icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF1CB0F6), size: 18),
                                label: const Text('Écouter', style: TextStyle(color: Color(0xFF1CB0F6), fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                          if (index == provider.currentQuestionIndex) ...[
                            const SizedBox(height: EkemaSpacing.lg),
                            ...question.options.asMap().entries.map((e) {
                              return StaggerFadeSlide(
                                index: e.key + 2,
                                child: DuoChoiceCard(
                                  title: e.value,
                                  subtitle: _subtitleForOption(e.value),
                                  icon: _iconForOption(e.value),
                                  onTap: () => _onAnswer(context, provider, e.value),
                                ),
                              );
                            }),
                          ],
                          const SizedBox(height: EkemaSpacing.xxl),
                        ],
                      );
                    },
                  ),
                ),
                _buildVoiceDock(context),
              ],
            ),
            if (_showXp)
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Center(child: DuoXpToast(xp: 15, onDone: () => setState(() => _showXp = false))),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonHeader(BuildContext context, dynamic procedure, ProcedureProvider provider) {
    return Container(
      padding: const EdgeInsets.all(EkemaSpacing.lg),
      decoration: const BoxDecoration(
        color: Color(0xFF1F2C33),
        border: Border(bottom: BorderSide(color: Color(0xFF37464F), width: 2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  procedure.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF58CC02).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF58CC02), width: 2),
                ),
                child: Text('$_xp XP', style: const TextStyle(color: Color(0xFF58CC02), fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DuoProgressBar(
            value: provider.progress,
            label: 'Question ${provider.currentQuestionIndex + 1} / ${procedure.questions.length}',
            color: const Color(0xFF58CC02),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceDock(BuildContext context) {
    final voice = context.watch<VoiceProvider>();
    return Container(
      margin: const EdgeInsets.all(EkemaSpacing.lg),
      padding: const EdgeInsets.symmetric(horizontal: EkemaSpacing.lg, vertical: EkemaSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2C33),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF37464F), width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0xFF37464F), blurRadius: 0, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              voice.isListening ? '🎤 Je vous écoute…' : 'Répondez à voix haute',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
            ),
          ),
          BouncyPress(
            onTap: () => voice.isListening
                ? voice.stopListening()
                : voice.startListening((res) => context.read<ProcedureProvider>().answerQuestion(res)),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: voice.isListening ? Colors.redAccent : const Color(0xFF1CB0F6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: voice.isListening ? Colors.red : const Color(0xFF1899D6),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: voice.isListening ? Colors.red : const Color(0xFF1899D6),
                    blurRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(voice.isListening ? Icons.stop_rounded : Icons.mic_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
