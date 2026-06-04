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
      backgroundColor: EkemaColors.subtle,
      appBar: AppBar(
        title: const Text('Historique'),
        leading: IconButton(
          icon: const Icon(Icons.close, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _history.isEmpty ? _buildEmptyState() : _buildHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(EkemaSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 72, color: EkemaColors.textSecondary.withValues(alpha: 0.25)),
            const SizedBox(height: EkemaSpacing.xl),
            Text(
              'Aucune démarche enregistrée',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: EkemaSpacing.sm),
            Text(
              'Vos procédures et documents apparaîtront ici.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: EkemaColors.textSecondary,
                  ),
            ),
            const SizedBox(height: EkemaSpacing.xl),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Explorer les démarches'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.separated(
      padding: const EdgeInsets.all(EkemaSpacing.lg),
      itemCount: _history.length,
      separatorBuilder: (_, __) => const SizedBox(height: EkemaSpacing.md),
      itemBuilder: (context, index) {
        final item = _history[index];
        final type = item['type'] as String;
        final date = DateTime.parse(item['date'] as String);
        final (icon, bg, fg) = _typeStyle(type);

        return ListingRow(
          icon: icon,
          iconBackground: bg,
          iconColor: fg,
          title: item['title'] as String,
          subtitle: '${date.day}/${date.month}/${date.year} · $type',
        );
      },
    );
  }

  (IconData, Color, Color) _typeStyle(String type) {
    if (type == 'document') {
      return (Icons.description_outlined, EkemaColors.infoLight, EkemaColors.info);
    }
    if (type == 'procedure') {
      return (Icons.assignment_outlined, EkemaColors.brandLight, EkemaColors.brand);
    }
    return (Icons.chat_bubble_outline, EkemaColors.subtle, EkemaColors.textSecondary);
  }
}
