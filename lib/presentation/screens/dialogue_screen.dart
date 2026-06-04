import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/procedure_provider.dart';
import '../providers/voice_provider.dart';
import '../widgets/design_system/design_system.dart';

class DialogueScreen extends StatefulWidget {
  const DialogueScreen({super.key});

  @override
  State<DialogueScreen> createState() => _DialogueScreenState();
}

class _DialogueScreenState extends State<DialogueScreen> {
  final ScrollController _scrollController = ScrollController();

  IconData _iconForOption(String option) {
    final lower = option.toLowerCase();
    if (lower.contains('première') || lower.contains('premiere')) return Icons.person_add_alt_1_outlined;
    if (lower.contains('renouvel')) return Icons.autorenew_rounded;
    if (lower.contains('oui')) return Icons.check_circle_outline;
    if (lower.contains('non')) return Icons.cancel_outlined;
    return Icons.touch_app_outlined;
  }

  String? _subtitleForOption(String option) {
    final lower = option.toLowerCase();
    if (lower.contains('première') || lower.contains('premiere')) return 'Jamais eu de CNI auparavant';
    if (lower.contains('renouvel')) return 'Carte expirée ou perdue';
    if (lower.contains('oui') && lower.contains('fiche')) return 'Pré-enrôlement idcam.cm terminé';
    if (lower.contains('non') && lower.contains('enrôl')) return 'Commencer le pré-enrôlement en ligne';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProcedureProvider>();
    final procedure = provider.selectedProcedure;

    if (procedure == null) {
      return const Scaffold(body: Center(child: Text('Aucune procédure sélectionnée.')));
    }

    return Scaffold(
      backgroundColor: EkemaColors.subtle,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, procedure, provider),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: EkemaSpacing.lg),
                itemCount: provider.currentQuestionIndex + 1,
                itemBuilder: (context, index) {
                  final question = procedure.questions[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: EkemaSpacing.lg),
                      _buildAssistantRow(question.text),
                      const SizedBox(height: EkemaSpacing.xl),
                      if (index == provider.currentQuestionIndex)
                        ...question.options.map(
                          (opt) => ChatChoiceCard(
                            title: opt,
                            subtitle: _subtitleForOption(opt),
                            icon: _iconForOption(opt),
                            onTap: () {
                              provider.answerQuestion(opt);
                              if (provider.state == ChatState.completed) {
                                Future.delayed(const Duration(milliseconds: 400), () {
                                  if (!context.mounted) return;
                                  Navigator.pushNamed(context, '/result');
                                });
                              }
                            },
                          ),
                        ),
                      const SizedBox(height: EkemaSpacing.md),
                    ],
                  );
                },
              ),
            ),
            _buildVoiceDock(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic procedure, ProcedureProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(EkemaSpacing.lg, EkemaSpacing.md, EkemaSpacing.lg, EkemaSpacing.lg),
      decoration: BoxDecoration(
        color: EkemaColors.canvas,
        boxShadow: EkemaShadows.sm,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(EkemaRadius.lg)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [EkemaColors.brand, EkemaColors.brandHover],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
              ),
              const SizedBox(width: EkemaSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      procedure.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'Assistant EKEMA · Hors ligne',
                      style: TextStyle(fontSize: 12, color: EkemaColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: EkemaColors.brandLight,
                  borderRadius: BorderRadius.circular(EkemaRadius.pill),
                ),
                child: Text(
                  '${provider.currentQuestionIndex + 1}/${procedure.questions.length}',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: EkemaColors.brand, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: EkemaSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(EkemaRadius.pill),
            child: LinearProgressIndicator(
              value: provider.progress,
              minHeight: 6,
              backgroundColor: EkemaColors.subtle,
              color: EkemaColors.brand,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssistantRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: EkemaColors.brandLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.auto_awesome, color: EkemaColors.brand, size: 18),
        ),
        const SizedBox(width: EkemaSpacing.md),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(EkemaSpacing.lg),
            decoration: BoxDecoration(
              color: EkemaColors.canvas,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(EkemaRadius.lg),
                bottomLeft: Radius.circular(EkemaRadius.lg),
                bottomRight: Radius.circular(EkemaRadius.lg),
              ),
              boxShadow: EkemaShadows.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: EkemaSpacing.sm),
                InkWell(
                  onTap: () => context.read<VoiceProvider>().speak(text),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.volume_up_rounded, size: 16, color: EkemaColors.brand.withValues(alpha: 0.9)),
                      const SizedBox(width: 4),
                      Text(
                        'Écouter',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: EkemaColors.brand),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceDock(BuildContext context) {
    final voice = context.watch<VoiceProvider>();
    return Container(
      margin: const EdgeInsets.all(EkemaSpacing.lg),
      padding: const EdgeInsets.symmetric(horizontal: EkemaSpacing.lg, vertical: EkemaSpacing.md),
      decoration: BoxDecoration(
        color: EkemaColors.textPrimary,
        borderRadius: BorderRadius.circular(EkemaRadius.pill),
        boxShadow: EkemaShadows.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              voice.isListening ? 'Je vous écoute…' : 'Appuyez sur le micro pour répondre',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 14,
              ),
            ),
          ),
          Material(
            color: voice.isListening ? Colors.redAccent : EkemaColors.brand,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => voice.isListening
                  ? voice.stopListening()
                  : voice.startListening((res) => context.read<ProcedureProvider>().answerQuestion(res)),
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 52,
                height: 52,
                child: Icon(
                  voice.isListening ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
