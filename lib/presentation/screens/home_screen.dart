import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/procedure_provider.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import '../widgets/design_system/design_system.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openCniDialogue(BuildContext context) {
    final provider = context.read<ProcedureProvider>();
    if (provider.procedures.isEmpty) return;
    provider.selectProcedure(provider.procedures.first);
    Navigator.pushNamed(context, '/dialogue');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EkemaColors.canvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: EkemaSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: EkemaSpacing.lg),
                    Text(
                      'Bonjour 👋',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: EkemaSpacing.xs),
                    Text(
                      'Comment puis-je vous aider aujourd\'hui ?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: EkemaColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: EkemaSpacing.xl),
                    EkemaSearchPill(
                      onSearch: (q) => context.read<ProcedureProvider>().search(q),
                      onVoiceTap: () {},
                    ),
                    const SectionHeader(title: 'Explorer'),
                    CategoryRail(items: _categories(context)),
                    const SectionHeader(title: 'Reprendre'),
                    ..._recentItems(context),
                    const SizedBox(height: EkemaSpacing.md),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HistoryScreen()),
                        ),
                        child: const Text('Voir tout l\'historique'),
                      ),
                    ),
                    const SizedBox(height: EkemaSpacing.xl),
                    const OfflinePill(),
                    const SizedBox(height: EkemaSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: EkemaBottomNav(
        currentIndex: 0,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(EkemaSpacing.lg, EkemaSpacing.md, EkemaSpacing.lg, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'EKEMA',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26),
          ),
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            borderRadius: BorderRadius.circular(EkemaRadius.pill),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: EkemaColors.brand, width: 2),
                color: EkemaColors.subtle,
              ),
              child: const Icon(Icons.person_outline, color: EkemaColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  List<CategoryItem> _categories(BuildContext context) {
    return [
      CategoryItem(
        icon: Icons.badge_outlined,
        label: 'CNI / Passeport',
        background: EkemaColors.categoryCni,
        iconColor: EkemaColors.brand,
        onTap: () => _openCniDialogue(context),
      ),
      CategoryItem(
        icon: Icons.description_outlined,
        label: 'Actes civils',
        background: EkemaColors.categoryCivil,
        iconColor: EkemaColors.info,
      ),
      CategoryItem(
        icon: Icons.business_outlined,
        label: 'Entreprise',
        background: EkemaColors.categoryBusiness,
        iconColor: EkemaColors.warning,
      ),
      CategoryItem(
        icon: Icons.school_outlined,
        label: 'Concours',
        background: EkemaColors.categorySchool,
        iconColor: const Color(0xFF7B2FF7),
      ),
      CategoryItem(
        icon: Icons.balance_outlined,
        label: 'Judiciaire',
        background: EkemaColors.categoryLegal,
        iconColor: EkemaColors.success,
      ),
      CategoryItem(
        icon: Icons.edit_note,
        label: 'Rédiger',
        background: EkemaColors.categoryWrite,
        iconColor: EkemaColors.textPrimary,
        onTap: () => Navigator.pushNamed(context, '/document-generator'),
      ),
    ];
  }

  List<Widget> _recentItems(BuildContext context) {
    final items = [
      ('Renouvellement CNI', 'Il y a 2 jours', Icons.badge_outlined, EkemaColors.categoryCni, EkemaColors.brand),
      ('Concours ENS 2026', 'Il y a 5 jours', Icons.school_outlined, EkemaColors.categorySchool, const Color(0xFF7B2FF7)),
      ('Demande de bourse', 'Il y a 1 semaine', Icons.description_outlined, EkemaColors.categoryCivil, EkemaColors.info),
    ];

    return items
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: EkemaSpacing.md),
            child: ListingRow(
              icon: item.$3,
              iconBackground: item.$4,
              iconColor: item.$5,
              title: item.$1,
              subtitle: item.$2,
              onTap: item.$1.contains('CNI') ? () => _openCniDialogue(context) : null,
            ),
          ),
        )
        .toList();
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        _openCniDialogue(context);
        break;
      case 2:
        final provider = context.read<ProcedureProvider>();
        if (provider.selectedProcedure != null && provider.state == ChatState.completed) {
          Navigator.pushNamed(context, '/result');
        } else {
          _openCniDialogue(context);
        }
        break;
      case 3:
        Navigator.pushNamed(context, '/document-generator');
        break;
    }
  }
}
