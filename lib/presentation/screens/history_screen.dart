import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/history_repository.dart';
import '../widgets/design_system/design_system.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryRepository _repository = HistoryRepository();
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _repository.getHistory();
    if (mounted) setState(() => _history = history);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CivioColors.subtle,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: CivioColors.brand,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Historique', style: TextStyle(fontWeight: FontWeight.w800)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [CivioColors.brand, CivioColors.brandHover],
                  ),
                ),
              ),
            ),
          ),
          if (_history.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.all(CivioSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = _history[index];
                    final type = item['type'] as String;
                    final date = DateTime.parse(item['date'] as String);
                    final (icon, gradient) = _style(type);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: CivioSpacing.lg),
                      child: ProcedureListingCard(
                        title: item['title'] as String,
                        location: '${date.day}/${date.month}/${date.year} · $type',
                        duration: 'Reprendre',
                        cost: 'Voir',
                        headerGradient: gradient,
                        icon: icon,
                        width: double.infinity,
                      ),
                    );
                  },
                  childCount: _history.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CivioSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: CivioColors.brandLight,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.history_rounded, size: 48, color: CivioColors.brand),
            ),
            const SizedBox(height: CivioSpacing.xl),
            Text('Aucune démarche', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22)),
            const SizedBox(height: CivioSpacing.sm),
            Text(
              'Vos parcours sauvegardés\napparaîtront ici.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: CivioColors.textSecondary),
            ),
            const SizedBox(height: CivioSpacing.xxl),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Explorer les démarches'),
            ),
          ],
        ),
      ),
    );
  }

  (IconData, List<Color>) _style(String type) {
    if (type == 'document') {
      return (Icons.description_outlined, [CivioColors.info, const Color(0xFF004CC4)]);
    }
    if (type == 'procedure') {
      return (Icons.assignment_outlined, [CivioColors.brand, CivioColors.brandHover]);
    }
    return (Icons.chat_bubble_outline, [const Color(0xFF888888), CivioColors.textPrimary]);
  }
}
