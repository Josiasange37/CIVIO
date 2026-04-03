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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Rédiger un document', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            Text('Génération officielle automatique', style: TextStyle(fontSize: 10, color: AppColors.muted)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.text),
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
        padding: const EdgeInsets.all(16),
        children: [
          _buildField('NOM COMPLET', _nameController, 'Ex: Jean Dupont'),
          const SizedBox(height: 16),
          _buildField('UNIVERSITÉ / ÉCOLE', _universityController, 'Ex: UY1'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildField('NIVEAU', _levelController, 'Ex: Master 1')),
              const SizedBox(width: 12),
              Expanded(child: _buildField('FILIÈRE', _majorController, 'Ex: Droit')),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _loading ? null : _doGenerate,
            child: _loading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('GÉNÉRER LE DOCUMENT PDF'),
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
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 0.4),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          validator: (v) => v!.isEmpty ? 'Requis' : null,
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Document généré avec succès', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
                      Text('Prêt à imprimer et signer', style: TextStyle(fontSize: 9, color: AppColors.primaryDark.withValues(alpha: 0.7))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary, width: 1.5),
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
                        style: const TextStyle(fontSize: 9, color: AppColors.muted),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'À l\'attention de M. le Ministre\nMINESUP — Yaoundé',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 14),
                    const Center(
                      child: Text(
                        'DEMANDE DE BOURSE NATIONALE',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, decoration: TextDecoration.underline),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Je soussignée ${_nameController.text}, étudiante en ${_levelController.text} de ${_majorController.text} à l\'${_universityController.text}, ai l\'honneur de solliciter l\'attribution d\'une bourse d\'études nationale.',
                      style: const TextStyle(fontSize: 11, height: 1.6),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Désireuse de poursuivre mon parcours académique avec excellence, je me permets de porter ma candidature à votre bienveillante attention.',
                      style: TextStyle(fontSize: 11, height: 1.6),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Veuillez agréer, Monsieur le Ministre, l\'expression de ma haute considération.',
                      style: TextStyle(fontSize: 11, height: 1.6),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        'Fait à Yaoundé, le ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}\n\n${_nameController.text}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => setState(() => _generated = false), child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 4),
                  Text('MODIFIER'),
                ],
              ))),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: ElevatedButton(
                onPressed: () async {
                  final bytes = await PdfGenerator.generateOfficialDocument(
                    title: 'DEMANDE DE BOURSE NATIONALE',
                    name: _nameController.text,
                    university: _universityController.text,
                    level: _levelController.text,
                    major: _majorController.text,
                    content: 'Je soussignée ${_nameController.text}, étudiante en ${_levelController.text} de ${_majorController.text} à l\'${_universityController.text}, ai l\'honneur de solliciter l\'attribution d\'une bourse d\'études nationale.\n\nDésireuse de poursuivre mon parcours académique avec excellence, je me permets de porter ma candidature à votre bienveillante attention.\n\nVeuillez agréer, Monsieur le Ministre, l\'expression de ma haute considération.',
                  );
                  await PdfGenerator.saveAndShare(bytes, 'demande_bourse_ekema.pdf');
                }, 
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download, size: 16),
                    SizedBox(width: 4),
                    Text('TÉLÉCHARGER PDF'),
                  ],
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }
}
