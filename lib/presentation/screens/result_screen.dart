import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/procedure_provider.dart';

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
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context, procedure),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'VOTRE PLAN PERSONNALISÉ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...procedure.steps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    return _buildStepCard(index, step);
                  }).toList(),
                  const SizedBox(height: 24),
                  _buildDocumentSection(procedure),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic procedure) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/')),
          ),
          const SizedBox(height: 12),
          Text(
            procedure.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Plan généré 100% hors ligne',
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBadge(Icons.attach_money, 'Env. ${procedure.steps[0].cost}'),
              const SizedBox(width: 8),
              _buildBadge(Icons.calendar_today, 'Délai ${procedure.steps[procedure.steps.length-1].time}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(int index, dynamic step) {
    final isCompleted = _completedSteps[index] ?? false;
    return InkWell(
      onTap: () => setState(() => _completedSteps[index] = !isCompleted),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted ? AppColors.primary : AppColors.border,
              width: isCompleted ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.primary : AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.description,
                      style: const TextStyle(fontSize: 11, height: 1.5, color: AppColors.muted),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (step.cost != "0 FCFA") ...[
                          _buildTag(Icons.account_balance_wallet, step.cost, AppColors.lightAmber, AppColors.amber),
                          const SizedBox(width: 6),
                        ],
                        _buildTag(Icons.schedule, step.time, AppColors.primaryLight, AppColors.primaryDark),
                      ],
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

  Widget _buildTag(IconData icon, String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 10, color: text),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: text),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentSection(dynamic procedure) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DOCUMENTS À PRÉPARER',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            children: (procedure.documents as List).map((doc) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.description, size: 14, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(doc, style: const TextStyle(fontSize: 12, color: AppColors.text))),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          _buildCircleAction(Icons.map_outlined, 'Carte'),
          const SizedBox(width: 8),
          _buildCircleAction(Icons.phone_outlined, 'Appeler'),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share, size: 18),
              label: const Text('PARTAGER'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366), // WhatsApp Green
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAction(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Icon(icon, size: 20, color: AppColors.text),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
