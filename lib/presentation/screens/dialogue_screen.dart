import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/procedure_provider.dart';
import '../providers/voice_provider.dart';

class DialogueScreen extends StatefulWidget {
  const DialogueScreen({super.key});

  @override
  State<DialogueScreen> createState() => _DialogueScreenState();
}

class _DialogueScreenState extends State<DialogueScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProcedureProvider>();
    final procedure = provider.selectedProcedure;

    if (procedure == null) {
      return const Scaffold(body: Center(child: Text('Aucune procédure sélectionnée.')));
    }

    return Scaffold(
      backgroundColor: EkemaColors.canvas,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              procedure.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
            ),
            Text(
              'Dialogue intelligent',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: EkemaColors.textSecondary,
                    fontSize: 12,
                  ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: EkemaSpacing.lg),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: EkemaColors.brandLight,
              borderRadius: BorderRadius.circular(EkemaRadius.pill),
            ),
            child: Text(
              '${provider.currentQuestionIndex + 1}/${procedure.questions.length}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: EkemaColors.brand,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: provider.progress,
            backgroundColor: EkemaColors.subtle,
            color: EkemaColors.brand,
            minHeight: 3,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(EkemaSpacing.lg),
              itemCount: provider.currentQuestionIndex + 1,
              itemBuilder: (context, index) {
                final question = procedure.questions[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBotBubble(question.text),
                    _buildSpeakButton(context, question.text),
                    const SizedBox(height: EkemaSpacing.lg),
                    if (index == provider.currentQuestionIndex)
                      _buildChoices(question.options, (choice) {
                        provider.answerQuestion(choice);
                        if (provider.state == ChatState.completed) {
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (!context.mounted) return;
                            Navigator.pushNamed(context, '/result');
                          });
                        }
                      }),
                    const SizedBox(height: EkemaSpacing.xl),
                  ],
                );
              },
            ),
          ),
          _buildInputBar(context),
        ],
      ),
    );
  }

  Widget _buildSpeakButton(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: EkemaSpacing.sm, left: EkemaSpacing.sm),
      child: InkWell(
        onTap: () => context.read<VoiceProvider>().speak(text),
        borderRadius: BorderRadius.circular(EkemaRadius.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.volume_up_rounded, size: 16, color: EkemaColors.brand.withValues(alpha: 0.9)),
              const SizedBox(width: 4),
              Text(
                'Écouter',
                style: TextStyle(
                  fontSize: 12,
                  color: EkemaColors.brand,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotBubble(String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: EkemaSpacing.lg, vertical: EkemaSpacing.md),
      decoration: BoxDecoration(
        color: EkemaColors.subtle,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(EkemaRadius.md),
          bottomLeft: Radius.circular(EkemaRadius.md),
          bottomRight: Radius.circular(EkemaRadius.md),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, height: 1.5, color: EkemaColors.textPrimary),
      ),
    );
  }

  Widget _buildChoices(List<String> options, Function(String) onChoice) {
    return Wrap(
      spacing: EkemaSpacing.sm,
      runSpacing: EkemaSpacing.sm,
      children: options.map((opt) {
        return Material(
          color: EkemaColors.canvas,
          borderRadius: BorderRadius.circular(EkemaRadius.pill),
          child: InkWell(
            onTap: () => onChoice(opt),
            borderRadius: BorderRadius.circular(EkemaRadius.pill),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(EkemaRadius.pill),
                border: Border.all(color: EkemaColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: EkemaSpacing.lg, vertical: EkemaSpacing.md),
                child: Text(
                  opt,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: EkemaColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    final voice = context.watch<VoiceProvider>();
    return Container(
      padding: const EdgeInsets.fromLTRB(EkemaSpacing.lg, EkemaSpacing.md, EkemaSpacing.lg, EkemaSpacing.xl),
      decoration: BoxDecoration(
        color: EkemaColors.canvas,
        border: Border(top: BorderSide(color: EkemaColors.border.withValues(alpha: 0.6))),
        boxShadow: EkemaShadows.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: EkemaSpacing.lg, vertical: EkemaSpacing.md),
              decoration: BoxDecoration(
                color: EkemaColors.subtle,
                borderRadius: BorderRadius.circular(EkemaRadius.pill),
              ),
              child: Text(
                voice.isListening ? 'Écoute en cours…' : 'Répondre ou parler…',
                style: TextStyle(
                  fontSize: 14,
                  color: EkemaColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: EkemaSpacing.md),
          Material(
            color: voice.isListening ? Colors.red : EkemaColors.brand,
            shape: const CircleBorder(),
            elevation: 3,
            child: InkWell(
              onTap: () => voice.isListening
                  ? voice.stopListening()
                  : voice.startListening((res) => context.read<ProcedureProvider>().answerQuestion(res)),
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  voice.isListening ? Icons.stop_rounded : Icons.mic,
                  color: EkemaColors.textInverse,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
