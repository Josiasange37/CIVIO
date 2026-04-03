import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paramètres', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: AppColors.text), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('PRÉFÉRENCES'),
          _buildLanguageTile(),
          _buildCityTile(),
          const SizedBox(height: 16),
          _buildSectionHeader('FONCTIONNALITÉS'),
          _buildVoiceTile(),
          _buildDarkModeTile(),
          const SizedBox(height: 16),
          _buildSectionHeader('À PROPOS'),
          _buildAboutTile(),
          _buildVersionTile(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 0.7),
      ),
    );
  }

  Widget _buildLanguageTile() {
    return Card(
      child: ListTile(
        title: const Text('Langue', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        trailing: DropdownButton<String>(
          value: _selectedLanguage,
          underline: Container(),
          onChanged: (String? newValue) => setState(() => _selectedLanguage = newValue!),
          items: ['Français', 'Camfranglais'].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCityTile() {
    return Card(
      child: ListTile(
        title: const Text('Ville par défaut', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        trailing: DropdownButton<String>(
          value: _selectedCity,
          underline: Container(),
          onChanged: (String? newValue) => setState(() => _selectedCity = newValue!),
          items: ['Yaoundé', 'Douala', 'Bafoussam', 'Garoua'].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildVoiceTile() {
    return Card(
      child: SwitchListTile(
        title: const Text('Assistant Vocal', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        subtitle: const Text('Parler pour interagir avec EKEMA', style: TextStyle(fontSize: 10)),
        value: _voiceEnabled,
        activeThumbColor: AppColors.primary,
        onChanged: (v) => setState(() => _voiceEnabled = v),
      ),
    );
  }

  Widget _buildDarkModeTile() {
    return Card(
      child: SwitchListTile(
        title: const Text('Mode sombre', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        value: _darkMode,
        activeThumbColor: AppColors.primary,
        onChanged: (v) => setState(() => _darkMode = v),
      ),
    );
  }

  Widget _buildAboutTile() {
    return const Card(
      child: ListTile(
        title: Text('EKEMA — Projet GCD4F 2026', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        subtitle: Text('Innovation IA pour la Société au Cameroun', style: TextStyle(fontSize: 10)),
      ),
    );
  }

  Widget _buildVersionTile() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          'Version 1.0.0 (Build 20260330)\n100% Hors Ligne',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 9, color: AppColors.muted),
        ),
      ),
    );
  }
}
