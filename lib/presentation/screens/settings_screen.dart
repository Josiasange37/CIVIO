import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/design_system/design_system.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _voiceEnabled = true;
  final bool _darkMode = false;
  String _selectedLanguage = 'Français';
  String _selectedCity = 'Yaoundé';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CivioColors.subtle,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            title: const Text('Paramètres'),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CivioColors.subtle,
                      CivioColors.brandLight.withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(CivioSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _profileCard(),
                const SizedBox(height: CivioSpacing.xl),
                const SectionHeader(title: 'Préférences'),
                _settingsGroup([
                  _dropdownTile('Langue', _selectedLanguage, ['Français', 'Camfranglais'], (v) {
                    setState(() => _selectedLanguage = v);
                  }),
                  const Divider(height: 1),
                  _dropdownTile('Ville', _selectedCity, ['Yaoundé', 'Douala', 'Bafoussam', 'Garoua'], (v) {
                    setState(() => _selectedCity = v);
                  }),
                ]),
                const SectionHeader(title: 'Fonctionnalités'),
                _settingsGroup([
                  SwitchListTile(
                    title: const Text('Assistant vocal', style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text('Interaction mains libres'),
                    value: _voiceEnabled,
                    activeThumbColor: CivioColors.brand,
                    onChanged: (v) => setState(() => _voiceEnabled = v),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Mode sombre'),
                    subtitle: const Text('Bientôt disponible'),
                    value: _darkMode,
                    onChanged: null,
                  ),
                ]),
                const SectionHeader(title: 'À propos'),
                _settingsGroup([
                  ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [CivioColors.brand, CivioColors.brandHover]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.bolt, color: Colors.white),
                    ),
                    title: const Text('Civio · GCD4F 2026', style: TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: const Text('IA pour la Société — Cameroun'),
                  ),
                ]),
                const SizedBox(height: CivioSpacing.xxl),
                Center(
                  child: Text('Version 2.1.0 · Design premium', style: Theme.of(context).textTheme.labelSmall),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(CivioSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF222222), Color(0xFF444444)],
        ),
        borderRadius: BorderRadius.circular(CivioRadius.lg),
        boxShadow: CivioShadows.md,
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: CivioColors.brand,
            child: Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: CivioSpacing.lg),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Citoyen·ne', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                Text('Yaoundé, Cameroun', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.6)),
        ],
      ),
    );
  }

  Widget _settingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: CivioColors.canvas,
        borderRadius: BorderRadius.circular(CivioRadius.lg),
        boxShadow: CivioShadows.sm,
      ),
      child: Column(children: children),
    );
  }

  Widget _dropdownTile(
    String title,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox.shrink(),
        items: options
            .map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(color: CivioColors.brand, fontWeight: FontWeight.w700))))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
