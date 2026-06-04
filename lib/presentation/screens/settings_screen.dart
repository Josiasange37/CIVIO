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
  bool _darkMode = false;
  String _selectedLanguage = 'Français';
  String _selectedCity = 'Yaoundé';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EkemaColors.subtle,
      appBar: AppBar(
        title: const Text('Paramètres'),
        leading: IconButton(
          icon: const Icon(Icons.close, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(EkemaSpacing.lg),
        children: [
          const SectionHeader(title: 'Préférences'),
          _settingsCard([
            _buildDropdownTile('Langue', _selectedLanguage, ['Français', 'Camfranglais'], (v) {
              setState(() => _selectedLanguage = v);
            }),
            const Divider(height: 1),
            _buildDropdownTile('Ville par défaut', _selectedCity, ['Yaoundé', 'Douala', 'Bafoussam', 'Garoua'], (v) {
              setState(() => _selectedCity = v);
            }),
          ]),
          const SectionHeader(title: 'Fonctionnalités'),
          _settingsCard([
            SwitchListTile(
              title: const Text('Assistant vocal'),
              subtitle: const Text('Parler pour interagir avec EKEMA'),
              value: _voiceEnabled,
              activeThumbColor: EkemaColors.brand,
              onChanged: (v) => setState(() => _voiceEnabled = v),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('Mode sombre'),
              subtitle: const Text('Bientôt disponible'),
              value: _darkMode,
              activeThumbColor: EkemaColors.brand,
              onChanged: null,
            ),
          ]),
          const SectionHeader(title: 'À propos'),
          _settingsCard([
            const ListTile(
              title: Text('EKEMA — Projet GCD4F 2026'),
              subtitle: Text('Innovation IA pour la Société au Cameroun'),
            ),
          ]),
          const SizedBox(height: EkemaSpacing.xl),
          Center(
            child: Text(
              'Version 2.0.0 · Design premium\n100% hors ligne',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: EkemaColors.canvas,
        borderRadius: BorderRadius.circular(EkemaRadius.md),
        boxShadow: EkemaShadows.sm,
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15)),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox.shrink(),
        items: options
            .map(
              (o) => DropdownMenuItem(
                value: o,
                child: Text(o, style: const TextStyle(fontWeight: FontWeight.w700, color: EkemaColors.brand)),
              ),
            )
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
