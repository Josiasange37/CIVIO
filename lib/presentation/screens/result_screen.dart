import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/procedure_provider.dart';
import '../widgets/design_system/design_system.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final Map<int, bool> _completedSteps = {};

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProcedureProvider>();
    final procedure = provider.selectedProcedure;

    if (procedure == null) return const Scaffold(body: Center(child: Text('Erreur')));

    return Scaffold(
      backgroundColor: EkemaColors.subtle,
      body: Column(
        children: [
          _buildHeader(context, procedure),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(EkemaSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Votre plan personnalisé'),
                  ...procedure.steps.asMap().entries.map((entry) {
                    return _buildStepCard(entry.key, entry.value);
                  }),
                  const SizedBox(height: EkemaSpacing.xl),
                  _buildDocumentSection(procedure),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic procedure) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(EkemaSpacing.lg, 56, EkemaSpacing.lg, EkemaSpacing.xl),
      color: EkemaColors.canvas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
            icon: const Icon(Icons.close, size: 26),
            onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/')),
          ),
          const SizedBox(height: EkemaSpacing.sm),
          Text(
            procedure.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: EkemaSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: EkemaColors.successLight,
              borderRadius: BorderRadius.circular(EkemaRadius.pill),
            ),
            child: const Text(
              '100% hors ligne',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: EkemaColors.success,
              ),
            ),
          ),
          const SizedBox(height: EkemaSpacing.lg),
          Row(
            children: [
              if (procedure.steps.isNotEmpty)
                EkemaTag(
                  icon: Icons.payments_outlined,
                  label: 'Env. ${procedure.steps[0].cost}',
                  variant: EkemaTagVariant.cost,
                ),
              const SizedBox(width: EkemaSpacing.sm),
              if (procedure.steps.isNotEmpty)
                EkemaTag(
                  icon: Icons.schedule,
                  label: 'Délai ${procedure.steps.last.time}',
                  variant: EkemaTagVariant.time,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(int index, dynamic step) {
    final isCompleted = _completedSteps[index] ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: EkemaSpacing.md),
      child: Material(
        color: EkemaColors.canvas,
        borderRadius: BorderRadius.circular(EkemaRadius.md),
        child: InkWell(
          onTap: () => setState(() => _completedSteps[index] = !isCompleted),
          borderRadius: BorderRadius.circular(EkemaRadius.md),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(EkemaRadius.md),
              boxShadow: EkemaShadows.sm,
              border: Border.all(
                color: isCompleted ? EkemaColors.brand : Colors.transparent,
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(EkemaSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted ? EkemaColors.brand : EkemaColors.brandLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, color: EkemaColors.textInverse, size: 18)
                          : Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: EkemaColors.brand,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: EkemaSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: EkemaSpacing.xs),
                        Text(
                          step.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: EkemaColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: EkemaSpacing.md),
                        Wrap(
                          spacing: EkemaSpacing.sm,
                          runSpacing: EkemaSpacing.sm,
                          children: [
                            if (step.cost != '0 FCFA')
                              EkemaTag(
                                icon: Icons.account_balance_wallet_outlined,
                                label: step.cost,
                                variant: EkemaTagVariant.cost,
                              ),
                            EkemaTag(
                              icon: Icons.schedule,
                              label: step.time,
                              variant: EkemaTagVariant.time,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentSection(dynamic procedure) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Documents à préparer'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(EkemaSpacing.lg),
          decoration: BoxDecoration(
            color: EkemaColors.canvas,
            borderRadius: BorderRadius.circular(EkemaRadius.md),
            boxShadow: EkemaShadows.sm,
          ),
          child: Column(
            children: (procedure.documents as List).map<Widget>((doc) {
              return Padding(
                padding: const EdgeInsets.only(bottom: EkemaSpacing.md),
                child: Row(
                  children: [
                    const Icon(Icons.description_outlined, size: 20, color: EkemaColors.info),
                    const SizedBox(width: EkemaSpacing.md),
                    Expanded(
                      child: Text(
                        doc,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(EkemaSpacing.lg, EkemaSpacing.md, EkemaSpacing.lg, EkemaSpacing.xl),
      decoration: BoxDecoration(
        color: EkemaColors.canvas,
        border: Border(top: BorderSide(color: EkemaColors.border.withValues(alpha: 0.8))),
        boxShadow: EkemaShadows.sm,
      ),
      child: Row(
        children: [
          _buildCircleAction(Icons.map_outlined),
          const SizedBox(width: EkemaSpacing.sm),
          _buildCircleAction(Icons.phone_outlined),
          const SizedBox(width: EkemaSpacing.md),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.ios_share, size: 18),
              label: const Text('Partager'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAction(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: EkemaColors.subtle,
        shape: BoxShape.circle,
        border: Border.all(color: EkemaColors.border),
      ),
      child: Icon(icon, size: 22, color: EkemaColors.textPrimary),
    );
  }
}
