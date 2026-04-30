import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/history_repository.dart';

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
    setState(() => _history = history);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historique', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: AppColors.text), onPressed: () => Navigator.pop(context)),
      ),
      body: _history.isEmpty ? _buildEmptyState() : _buildHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: AppColors.muted.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text('Aucune démarche enregistrée', style: TextStyle(color: AppColors.muted, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        final type = item['type'];
        final date = DateTime.parse(item['date']);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: _buildTypeIcon(type),
            title: Text(item['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: Text(
              '${date.day}/${date.month}/${date.year} · $type',
              style: const TextStyle(fontSize: 10, color: AppColors.muted),
            ),
            trailing: const Icon(Icons.chevron_right, size: 16, color: AppColors.muted),
            onTap: () {},
          ),
        );
      },
    );
  }

  Widget _buildTypeIcon(String type) {
    IconData icon;
    Color color;
    if (type == 'document') {
      icon = Icons.description;
      color = AppColors.primary;
    } else if (type == 'procedure') {
      icon = Icons.assignment;
      color = AppColors.indigo;
    } else {
      icon = Icons.chat;
      color = AppColors.muted;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
