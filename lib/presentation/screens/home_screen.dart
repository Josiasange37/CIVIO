import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';
import '../providers/procedure_provider.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import '../widgets/animations/animations.dart';
import '../widgets/design_system/design_system.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _filterIndex = 0;

  void _openCniDialogue(BuildContext context) {
    final provider = context.read<ProcedureProvider>();
    if (provider.procedures.isEmpty) return;
    provider.selectProcedure(provider.procedures.first);
    Navigator.pushNamed(context, '/dialogue');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CivioColors.subtle,
      extendBody: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: CivioColors.subtle,
            title: Row(
              children: [
                SvgPicture.asset(
                  'assets/civio_logo.svg',
                  height: 32,
                  width: 32,
                ),
                const SizedBox(width: 10),
                Text(
                  'Civio',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.person_outline_rounded),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(CivioSpacing.lg, 0, CivioSpacing.lg, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StaggerFadeSlide(
                    index: 0,
                    child: Text(
                      'Vos démarches,\ncomme un séjour premium.',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: 28,
                            height: 1.15,
                            letterSpacing: -0.8,
                          ),
                    ),
                  ),
                  const SizedBox(height: CivioSpacing.xl),
                  StaggerFadeSlide(
                    index: 1,
                    child: SegmentedSearchBar(
                      onTap: () => _openCniDialogue(context),
                      onVoiceTap: () => Navigator.pushNamed(context, '/ai-chat'),
                    ),
                  ),
                  const SizedBox(height: CivioSpacing.xxl),
                  StaggerFadeSlide(
                    index: 2,
                    child: FeatureSpotlightCard(
                    badge: 'Tendance · Yaoundé',
                    title: 'Carte Nationale\nd\'Identité',
                    subtitle: 'Guide pas à pas · 100% hors ligne · IDCAM',
                    ctaLabel: 'Commencer la démarche',
                    gradient: const [Color(0xFFFF385C), Color(0xFFE31C5F), Color(0xFFBD1E59)],
                    icon: Icons.badge_outlined,
                    onTap: () => _openCniDialogue(context),
                    ),
                  ),
                  const SizedBox(height: CivioSpacing.xxl),
                  StaggerFadeSlide(
                    index: 3,
                    child: BouncyPress(
                      onTap: () => Navigator.pushNamed(context, '/ai-chat'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(CivioSpacing.lg),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2C33),
                          borderRadius: BorderRadius.circular(CivioRadius.lg),
                          border: Border.all(color: const Color(0xFF37464F), width: 2),
                          boxShadow: const [
                            BoxShadow(color: Color(0xFF37464F), blurRadius: 0, offset: Offset(0, 4)),
                          ],
                        ),
                        child: const Row(
                          children: [
                            DuoMascot(size: 56, mood: 'happy'),
                            SizedBox(width: CivioSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Chat IA Civio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                                  Text('Posez n\'importe quelle question', style: TextStyle(color: Colors.white54, fontSize: 13)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: Color(0xFF58CC02)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: CivioSpacing.xxl),
                  StaggerFadeSlide(
                    index: 4,
                    child: FilterChipRow(
                    labels: const ['Populaires', 'CNI', 'Concours', 'Bourses', 'Entreprise'],
                    selectedIndex: _filterIndex,
                    onSelected: (i) => setState(() => _filterIndex = i),
                    ),
                  ),
                  const SizedBox(height: CivioSpacing.xl),
                  StaggerFadeSlide(
                    index: 5,
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Procédures à découvrir',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HistoryScreen()),
                        ),
                        child: const Text('Historique'),
                      ),
                    ],
                  ),
                  ),
                  const SizedBox(height: CivioSpacing.lg),
                  StaggerFadeSlide(
                    index: 6,
                    child: SizedBox(
                      height: 280,
                      child: ListView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      children: [
                        ProcedureListingCard(
                          title: 'CNI — Première demande',
                          location: 'Yaoundé · IDCAM',
                          duration: '2–4 sem.',
                          cost: '20 000 F',
                          headerGradient: const [Color(0xFFFF6B8A), Color(0xFFFF385C)],
                          icon: Icons.badge_outlined,
                          onTap: () => _openCniDialogue(context),
                        ),
                        const SizedBox(width: CivioSpacing.lg),
                        const ProcedureListingCard(
                          title: 'Concours ENS 2026',
                          location: 'National · MINESUP',
                          duration: '3 mois',
                          cost: '5 000 F',
                          headerGradient: [Color(0xFF9B6DFF), Color(0xFF7B2FF7)],
                          icon: Icons.school_outlined,
                        ),
                        const SizedBox(width: CivioSpacing.lg),
                        const ProcedureListingCard(
                          title: 'Création d\'entreprise',
                          location: 'CFCE · Guichet unique',
                          duration: '48 h',
                          cost: 'Variable',
                          headerGradient: [Color(0xFFFFB347), Color(0xFFE07912)],
                          icon: Icons.business_center_outlined,
                        ),
                      ],
                    ),
                  ),
                  ),
                  const SizedBox(height: CivioSpacing.xxl),
                  StaggerFadeSlide(
                    index: 7,
                    child: Text(
                      'Parcourir par thème',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: CivioSpacing.lg),
                  StaggerFadeSlide(
                    index: 8,
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: CivioSpacing.md,
                      crossAxisSpacing: CivioSpacing.md,
                      childAspectRatio: 0.92,
                      children: [
                      CategoryGridTile(
                        title: 'CNI & Passeport',
                        subtitle: 'IDCAM · PASSCAM',
                        icon: Icons.badge_outlined,
                        gradient: const [Color(0xFFFF385C), Color(0xFFE31C5F)],
                        onTap: () => _openCniDialogue(context),
                      ),
                      const CategoryGridTile(
                        title: 'Actes civils',
                        subtitle: 'Naissance · Mariage',
                        icon: Icons.description_outlined,
                        gradient: [Color(0xFF4A90FF), Color(0xFF004CC4)],
                      ),
                      const CategoryGridTile(
                        title: 'Concours & Études',
                        subtitle: 'ENS · Bourses',
                        icon: Icons.school_outlined,
                        gradient: [Color(0xFF9B6DFF), Color(0xFF7B2FF7)],
                      ),
                      CategoryGridTile(
                        title: 'Rédiger un document',
                        subtitle: 'Lettres · PDF officiel',
                        icon: Icons.edit_document,
                        gradient: const [Color(0xFF444444), Color(0xFF222222)],
                        onTap: () => Navigator.pushNamed(context, '/document-generator'),
                      ),
                    ],
                  ),
                  ),
                  const SizedBox(height: CivioSpacing.xxl),
                  StaggerFadeSlide(
                    index: 9,
                    child: BouncyPress(
                      onTap: () => Navigator.pushNamed(context, '/map'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(CivioSpacing.xl),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF1CB0F6), Color(0xFF1899D6)]),
                          borderRadius: BorderRadius.circular(CivioRadius.lg),
                          boxShadow: const [
                            BoxShadow(color: Color(0xFF1899D6), blurRadius: 0, offset: Offset(0, 4)),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.map_rounded, color: Colors.white, size: 32),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Carte interactive', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
                                  Text('Trouvez les bureaux administratifs', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: CivioSpacing.lg),
                  StaggerFadeSlide(
                    index: 10,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(CivioSpacing.xl),
                      decoration: BoxDecoration(
                        color: CivioColors.canvas,
                        borderRadius: BorderRadius.circular(CivioRadius.lg),
                        boxShadow: CivioShadows.md,
                      ),
                      child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: CivioColors.successLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.wifi_off_rounded, color: CivioColors.success, size: 28),
                        ),
                        const SizedBox(width: CivioSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Toujours disponible',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Procédures stockées localement. L\'IA en ligne est un bonus.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: CivioColors.textSecondary,
                                      fontSize: 13,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: FloatingNavBar(
        currentIndex: 0,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/ai-chat');
        break;
      case 2:
        Navigator.pushNamed(context, '/map');
        break;
      case 3:
        Navigator.pushNamed(context, '/document-generator');
        break;
    }
  }
}
