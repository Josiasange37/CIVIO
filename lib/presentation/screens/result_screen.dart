import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/procedure_provider.dart';
import '../widgets/design_system/design_system.dart';
import '../widgets/animations/animations.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final Map<int, bool> _completedSteps = {};
  int? _expandedIndex = 0;
  bool _showCelebrate = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showCelebrate = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProcedureProvider>();
    final procedure = provider.selectedProcedure;

    if (procedure == null) return const Scaffold(body: Center(child: Text('Erreur')));

    return Scaffold(
      backgroundColor: const Color(0xFF131F24),
      bottomNavigationBar: _buildBottomSheet(context),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHero(context, procedure)),
              SliverToBoxAdapter(child: _buildStatsRow(procedure)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(EkemaSpacing.lg, EkemaSpacing.xl, EkemaSpacing.lg, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    StaggerFadeSlide(
                      index: 0,
                      child: MascotSpeechBubble(
                        text: 'Bravo ! Voici votre plan personnalisé. Cochez chaque étape terminée.',
                        mascot: const DuoMascot(size: 64, mood: 'celebrate'),
                      ),
                    ),
                    const SizedBox(height: EkemaSpacing.xl),
                    ...procedure.steps.asMap().entries.map((entry) {
                      final index = entry.key;
                      final step = entry.value;
                      final expanded = _expandedIndex == index;
                      final completed = _completedSteps[index] ?? false;
                      return StepAccordionCard(
                        index: index + 1,
                        title: step.title,
                        description: step.description,
                        cost: step.cost,
                        time: step.time,
                        isExpanded: expanded,
                        isCompleted: completed,
                        onTap: () => setState(() => _expandedIndex = expanded ? null : index),
                        onToggleComplete: () => setState(() => _completedSteps[index] = !completed),
                      );
                    }),
                    const SizedBox(height: EkemaSpacing.xxl),
                    _buildDocumentsCard(procedure),
                  ]),
                ),
              ),
            ],
          ),
          if (_showCelebrate)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const DuoMascot(size: 120, mood: 'celebrate'),
                    const SizedBox(height: 24),
                    DuoXpToast(xp: 50, onDone: () => setState(() => _showCelebrate = false)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, dynamic procedure) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF58CC02), Color(0xFF46A302), Color(0xFF2B7A0B)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(EkemaSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/')),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(EkemaRadius.pill),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.offline_bolt, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('100% hors ligne', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                procedure.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Plan personnalisé généré pour vous',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(dynamic procedure) {
    final steps = procedure.steps as List;
    return Transform.translate(
      offset: const Offset(0, -28),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: EkemaSpacing.lg),
        child: Row(
          children: [
            Expanded(child: _statCard(Icons.format_list_numbered, '${steps.length} étapes', 'Parcours')),
            const SizedBox(width: EkemaSpacing.md),
            Expanded(
              child: _statCard(
                Icons.payments_outlined,
                steps.isNotEmpty ? steps.first.cost : '—',
                'Coût estimé',
              ),
            ),
            const SizedBox(width: EkemaSpacing.md),
            Expanded(
              child: _statCard(
                Icons.schedule,
                steps.isNotEmpty ? steps.last.time : '—',
                'Délai',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(EkemaSpacing.lg),
      decoration: BoxDecoration(
        color: EkemaColors.canvas,
        borderRadius: BorderRadius.circular(EkemaRadius.md),
        boxShadow: EkemaShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: EkemaColors.brand),
          const SizedBox(height: EkemaSpacing.sm),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(label, style: const TextStyle(fontSize: 11, color: EkemaColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildDocumentsCard(dynamic procedure) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(EkemaSpacing.xl),
      decoration: BoxDecoration(
        color: EkemaColors.canvas,
        borderRadius: BorderRadius.circular(EkemaRadius.lg),
        boxShadow: EkemaShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Documents à préparer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: EkemaSpacing.lg),
          ...(procedure.documents as List).map<Widget>((doc) {
            return Container(
              margin: const EdgeInsets.only(bottom: EkemaSpacing.sm),
              padding: const EdgeInsets.all(EkemaSpacing.lg),
              decoration: BoxDecoration(
                color: EkemaColors.infoLight,
                borderRadius: BorderRadius.circular(EkemaRadius.sm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined, color: EkemaColors.info),
                  const SizedBox(width: EkemaSpacing.md),
                  Expanded(child: Text(doc, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(EkemaSpacing.lg, EkemaSpacing.lg, EkemaSpacing.lg, EkemaSpacing.xl),
      decoration: BoxDecoration(
        color: EkemaColors.canvas,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(EkemaRadius.lg)),
        boxShadow: EkemaShadows.lg,
      ),
      child: Row(
        children: [
          _circleBtn(Icons.map_outlined, onTap: () => Navigator.pushNamed(context, '/map')),
          const SizedBox(width: EkemaSpacing.sm),
          _circleBtn(Icons.phone_outlined),
          const SizedBox(width: EkemaSpacing.md),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/document-generator'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EkemaRadius.sm)),
              ),
              child: const Text('Générer un document'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, {VoidCallback? onTap}) {
    return BouncyPress(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF1F2C33),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF37464F), width: 2),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
