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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.text, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(procedure.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const Text('Dialogue intelligent', style: TextStyle(fontSize: 10, color: AppColors.muted)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              label: Text('${provider.currentQuestionIndex}/${procedure.questions.length} questions'),
              labelStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
              backgroundColor: AppColors.primaryLight,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: provider.progress,
            backgroundColor: AppColors.border,
            color: AppColors.primary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.currentQuestionIndex + 1,
              itemBuilder: (context, index) {
                final question = procedure.questions[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBotBubble(question.text),
                    _buildSpeakButton(context, question.text),
                    const SizedBox(height: 12),
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
      padding: const EdgeInsets.only(top: 4),
      child: InkWell(
        onTap: () => context.read<VoiceProvider>().speak(text),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.volume_up, size: 14, color: AppColors.primary),
            SizedBox(width: 4),
            Text('Écouter la question', style: TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildBotBubble(String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(14),
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, height: 1.5, color: AppColors.text)),
    );
  }

  Widget _buildChoices(List<String> options, Function(String) onChoice) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) => InkWell(
        onTap: () => onChoice(opt),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary, width: 1),
          ),
          child: Text(
            opt,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    final voice = context.watch<VoiceProvider>();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                voice.isListening ? 'Écoute en cours...' : 'Répondre ou parler...', 
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => voice.isListening 
                ? voice.stopListening() 
                : voice.startListening((res) => context.read<ProcedureProvider>().answerQuestion(res)),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: voice.isListening ? Colors.red : AppColors.primary, 
                shape: BoxShape.circle,
              ),
              child: Icon(voice.isListening ? Icons.stop : Icons.mic, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
