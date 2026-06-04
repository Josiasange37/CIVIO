import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/pdf_generator.dart';

class DocumentGeneratorScreen extends StatefulWidget {
  const DocumentGeneratorScreen({super.key});

  @override
  State<DocumentGeneratorScreen> createState() => _DocumentGeneratorScreenState();
}

class _DocumentGeneratorScreenState extends State<DocumentGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController(text: 'Fatima MBARGA');
  final TextEditingController _universityController = TextEditingController(text: 'Université de Yaoundé II');
  final TextEditingController _levelController = TextEditingController(text: 'Master 1');
  final TextEditingController _majorController = TextEditingController(text: 'Droit public');

  bool _generated = false;
  bool _loading = false;

  void _doGenerate() {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _generated = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EkemaColors.subtle,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rédiger un document', style: Theme.of(context).textTheme.titleMedium),
            Text(
              'Génération officielle automatique',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: EkemaColors.textSecondary,
                    fontSize: 12,
                  ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _generated ? _buildPreview() : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(EkemaSpacing.lg),
        children: [
          _buildField('Nom complet', _nameController, 'Ex: Jean Dupont'),
          const SizedBox(height: EkemaSpacing.lg),
          _buildField('Université / École', _universityController, 'Ex: UY1'),
          const SizedBox(height: EkemaSpacing.lg),
          Row(
            children: [
              Expanded(child: _buildField('Niveau', _levelController, 'Ex: Master 1')),
              const SizedBox(width: EkemaSpacing.md),
              Expanded(child: _buildField('Filière', _majorController, 'Ex: Droit')),
            ],
          ),
          const SizedBox(height: EkemaSpacing.xxl),
          ElevatedButton(
            onPressed: _loading ? null : _doGenerate,
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: EkemaColors.textInverse, strokeWidth: 2),
                  )
                : const Text('Générer le document PDF'),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: EkemaSpacing.sm),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
          validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Padding(
      padding: const EdgeInsets.all(EkemaSpacing.lg),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(EkemaSpacing.lg),
            decoration: BoxDecoration(
              color: EkemaColors.successLight,
              borderRadius: BorderRadius.circular(EkemaRadius.md),
              border: Border.all(color: EkemaColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: EkemaColors.success, size: 24),
                const SizedBox(width: EkemaSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Document généré avec succès',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: EkemaColors.success,
                              fontSize: 14,
                            ),
                      ),
                      Text(
                        'Prêt à imprimer et signer',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: EkemaColors.textSecondary,
                              fontSize: 13,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: EkemaSpacing.lg),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(EkemaSpacing.xl),
              decoration: BoxDecoration(
                color: EkemaColors.canvas,
                borderRadius: BorderRadius.circular(EkemaRadius.md),
                boxShadow: EkemaShadows.md,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        '${_nameController.text}\nYaoundé, le ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: EkemaColors.textSecondary,
                              fontSize: 12,
                            ),
                      ),
                    ),
                    const SizedBox(height: EkemaSpacing.lg),
                    const Text(
                      'À l\'attention de M. le Ministre\nMINESUP — Yaoundé',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: EkemaSpacing.lg),
                    const Center(
                      child: Text(
                        'DEMANDE DE BOURSE NATIONALE',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, decoration: TextDecoration.underline),
                      ),
                    ),
                    const SizedBox(height: EkemaSpacing.lg),
                    Text(
                      'Je soussignée ${_nameController.text}, étudiante en ${_levelController.text} de ${_majorController.text} à l\'${_universityController.text}, ai l\'honneur de solliciter l\'attribution d\'une bourse d\'études nationale.',
                      style: const TextStyle(fontSize: 14, height: 1.6),
                    ),
                    const SizedBox(height: EkemaSpacing.md),
                    const Text(
                      'Désireuse de poursuivre mon parcours académique avec excellence, je me permets de porter ma candidature à votre bienveillante attention.',
                      style: TextStyle(fontSize: 14, height: 1.6),
                    ),
                    const SizedBox(height: EkemaSpacing.md),
                    const Text(
                      'Veuillez agréer, Monsieur le Ministre, l\'expression de ma haute considération.',
                      style: TextStyle(fontSize: 14, height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: EkemaSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _generated = false),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Modifier'),
                ),
              ),
              const SizedBox(width: EkemaSpacing.md),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final bytes = await PdfGenerator.generateOfficialDocument(
                      title: 'DEMANDE DE BOURSE NATIONALE',
                      name: _nameController.text,
                      university: _universityController.text,
                      level: _levelController.text,
                      major: _majorController.text,
                      content:
                          'Je soussignée ${_nameController.text}, étudiante en ${_levelController.text} de ${_majorController.text} à l\'${_universityController.text}, ai l\'honneur de solliciter l\'attribution d\'une bourse d\'études nationale.\n\nDésireuse de poursuivre mon parcours académique avec excellence, je me permets de porter ma candidature à votre bienveillante attention.\n\nVeuillez agréer, Monsieur le Ministre, l\'expression de ma haute considération.',
                    );
                    await PdfGenerator.saveAndShare(bytes, 'demande_bourse_ekema.pdf');
                  },
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Télécharger PDF'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
